import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../db/app_database.dart';
import '../repositories/attachments_repository.dart';
import '../repositories/notes_repository.dart';

/// Weekly encrypted backup: notes, versions, the reminder list, lessons,
/// app_settings and attachment rows as JSON in a ZIP — with the voice clips
/// and pictures themselves under `attachments/` (videos are left out) — the whole ZIP encrypted
/// with AES-256-GCM derived from the user password via PBKDF2. Without the
/// password the file cannot be opened.
class BackupService {
  BackupService(this.db, {AttachmentsRepository? attachments})
    : attachments = attachments ?? AttachmentsRepository(db);

  final AppDatabase db;
  final AttachmentsRepository attachments;

  static const keptBackups = 8;
  static const _magic = 'DTBK2'; // format marker + version (.dtbak)

  /// Settings that are device state, not user data.
  static const _deviceSettings = {
    NotesRepository.cursorNoteKey,
    NotesRepository.cursorSlotKey,
    'relay_done',
  };

  /// File-name prefix of this app's backups; pruning only touches these.
  static const filePrefix = 'local_harness_not_';

  static final _aes = AesGcm.with256bits();

  static Pbkdf2 get _kdf =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 150000, bits: 256);

  Future<Uint8List> _zipBytes() async {
    final settings = await db.select(db.appSettings).get();
    final archive = Archive();

    void add(String name, Object content) {
      final bytes = utf8.encode(jsonEncode(content));
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    add('notes.json', [
      for (final n in await db.select(db.notes).get()) n.toJson(),
    ]);
    add('note_versions.json', [
      for (final v in await db.select(db.noteVersions).get()) v.toJson(),
    ]);
    add('reminders.json', [
      for (final r in await db.select(db.reminders).get()) r.toJson(),
    ]);
    add('app_settings.json', {
      for (final s in settings)
        if (!_deviceSettings.contains(s.key)) s.key: s.value,
    });
    add('lessons.json', [
      for (final l in await db.select(db.lessons).get()) l.toJson(),
    ]);
    // Videos stay out: they would make every weekly backup huge.
    final rows = [
      for (final a in await db.select(db.noteAttachments).get())
        if (a.kind != 'video') a,
    ];
    add('note_attachments.json', [for (final a in rows) a.toJson()]);
    for (final a in rows) {
      for (final f in [
        await attachments.fileOf(a),
        await attachments.notificationFileOf(a),
      ]) {
        final name = 'attachments/${p.basename(f.path)}';
        if (archive.findFile(name) != null || !await f.exists()) continue;
        final bytes = await f.readAsBytes();
        archive.addFile(ArchiveFile(name, bytes.length, bytes));
      }
    }
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  /// Restores a decrypted backup ZIP: notes are upserted by id (newer
  /// local edits are kept), versions and settings added, and the reminder
  /// list replaced. Returns the number of notes restored.
  Future<int> restoreZip(Uint8List zip) async {
    final entries = ZipDecoder().decodeBytes(zip).files;
    final files = {
      for (final f in entries)
        if (f.name.endsWith('.json'))
          f.name: jsonDecode(utf8.decode(f.content as List<int>)),
    };
    final media = {
      for (final f in entries)
        if (f.name.startsWith('attachments/'))
          p.basename(f.name): f.content as List<int>,
    };
    final repo = NotesRepository(db);
    var restored = 0;
    await db.transaction(() async {
      for (final raw in (files['notes.json'] as List? ?? const [])) {
        final note = Note.fromJson((raw as Map).cast<String, dynamic>());
        final local = await repo.getNote(note.id);
        if (local != null && local.updatedAt >= note.updatedAt) continue;
        await db.into(db.notes).insertOnConflictUpdate(note);
        await repo.updateBody(note.id, note.body);
        await (db.update(db.notes)..where((n) => n.id.equals(note.id))).write(
          NotesCompanion(updatedAt: Value(note.updatedAt)),
        );
        restored++;
      }
      final known = {
        for (final v in await db.select(db.noteVersions).get())
          '${v.noteId}|${v.createdAt}|${v.body.hashCode}',
      };
      for (final raw in (files['note_versions.json'] as List? ?? const [])) {
        final v = NoteVersion.fromJson((raw as Map).cast<String, dynamic>());
        if (known.contains('${v.noteId}|${v.createdAt}|${v.body.hashCode}')) {
          continue;
        }
        await db
            .into(db.noteVersions)
            .insert(
              NoteVersionsCompanion.insert(
                noteId: v.noteId,
                body: v.body,
                reason: v.reason,
                createdAt: v.createdAt,
              ),
            );
      }
      final reminders = files['reminders.json'] as List?;
      if (reminders != null && reminders.isNotEmpty) {
        await db.delete(db.reminders).go();
        for (final raw in reminders) {
          await db
              .into(db.reminders)
              .insert(Reminder.fromJson((raw as Map).cast<String, dynamic>()));
        }
      }
      for (final raw in (files['lessons.json'] as List? ?? const [])) {
        final lesson = Lesson.fromJson((raw as Map).cast<String, dynamic>());
        final local = await (db.select(
          db.lessons,
        )..where((l) => l.id.equals(lesson.id))).getSingleOrNull();
        if (local != null && local.updatedAt >= lesson.updatedAt) continue;
        await db.into(db.lessons).insertOnConflictUpdate(lesson);
      }
      for (final raw in (files['note_attachments.json'] as List? ?? const [])) {
        final a = NoteAttachment.fromJson((raw as Map).cast<String, dynamic>());
        final bytes = media[a.file];
        if (bytes == null || await repo.getNote(a.noteId) == null) continue;
        final exists = await (db.select(
          db.noteAttachments,
        )..where((x) => x.id.equals(a.id))).getSingleOrNull();
        if (exists != null) continue;
        await (await attachments.fileOf(a)).writeAsBytes(bytes);
        final smallName = '${p.basenameWithoutExtension(a.file)}_n.jpg';
        final small = media[smallName];
        if (small != null) {
          final dir = (await attachments.fileOf(a)).parent.path;
          await File(p.join(dir, smallName)).writeAsBytes(small);
        }
        await db.into(db.noteAttachments).insert(a);
      }
      final settings = files['app_settings.json'] as Map? ?? const {};
      for (final e in settings.entries) {
        await db
            .into(db.appSettings)
            .insertOnConflictUpdate(
              AppSettingsCompanion.insert(key: '${e.key}', value: '${e.value}'),
            );
      }
    });
    return restored;
  }

  /// Layout: magic | salt(16) | nonce(12) | ciphertext | mac(16).
  Future<Uint8List> createEncryptedBackup(String password) async {
    final zip = await _zipBytes();
    final salt = SecretKeyData.random(length: 16).bytes;
    final secretKey = await _kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    final secretBox = await _aes.encrypt(zip, secretKey: secretKey);

    final builder = BytesBuilder();
    builder.add(utf8.encode(_magic));
    builder.add(salt);
    builder.add(secretBox.nonce); // 12 bytes
    builder.add(secretBox.cipherText);
    builder.add(secretBox.mac.bytes); // 16 bytes
    return builder.toBytes();
  }

  /// Throws on a wrong password (MAC verification fails).
  static Future<Uint8List> decryptBackup(
    Uint8List data,
    String password,
  ) async {
    final magic = utf8.decode(data.sublist(0, _magic.length));
    if (magic != _magic) {
      throw const FormatException('Not a Not (local_harness_not) backup');
    }
    var offset = _magic.length;
    final salt = data.sublist(offset, offset + 16);
    offset += 16;
    final nonce = data.sublist(offset, offset + 12);
    offset += 12;
    final mac = data.sublist(data.length - 16);
    final cipherText = data.sublist(offset, data.length - 16);

    final secretKey = await _kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    final clear = await _aes.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: secretKey,
    );
    return Uint8List.fromList(clear);
  }

  /// Writes a timestamped backup into [directory] and prunes old ones.
  Future<File> backupTo(
    Directory directory,
    String password, {
    DateTime? now,
  }) async {
    final stamp = (now ?? DateTime.now())
        .toIso8601String()
        .substring(0, 19)
        .replaceAll(':', '-');
    final file = File(p.join(directory.path, '$filePrefix$stamp.dtbak'));
    await file.writeAsBytes(await createEncryptedBackup(password));
    await pruneOldBackups(directory);
    return file;
  }

  /// Keeps the newest [keptBackups] files, deletes the rest (spec 10.3).
  Future<List<String>> pruneOldBackups(Directory directory) async {
    final backups =
        directory
            .listSync()
            .whereType<File>()
            .where(
              (f) =>
                  p.basename(f.path).startsWith(filePrefix) &&
                  f.path.endsWith('.dtbak'),
            )
            .toList()
          ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    final deleted = <String>[];
    for (final old in backups.skip(keptBackups)) {
      deleted.add(old.path);
      await old.delete();
    }
    return deleted;
  }

  /// Next Sunday 03:00 strictly after [now] (spec 10.3).
  static DateTime nextWeeklyRun(DateTime now) {
    var candidate = DateTime(now.year, now.month, now.day, 3);
    while (candidate.weekday != DateTime.sunday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}

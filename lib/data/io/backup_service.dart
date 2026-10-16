import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;

import '../db/app_database.dart';
import 'export_service.dart';

/// Weekly encrypted backup (spec 10.3): entries + metrics CSVs and
/// app_settings in a ZIP,
/// the whole ZIP encrypted with AES-256-GCM derived from the user password
/// via PBKDF2. Without the password the file cannot be opened.
class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  static const keptBackups = 8;
  static const _magic = 'DTBK1'; // format marker + version (.dtbak)

  /// File-name prefix of this app's backups; pruning only touches these.
  static const filePrefix = 'local_harness_not_';

  static final _aes = AesGcm.with256bits();

  static Pbkdf2 get _kdf =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 150000, bits: 256);

  Future<Uint8List> _zipBytes() async {
    final export = ExportService(db);
    final settings = await db.select(db.appSettings).get();
    final archive = Archive();

    void add(String name, String content) {
      final bytes = utf8.encode(content);
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    add('entries.csv', await export.entriesCsv());
    add('metrics.csv', await export.metricsCsv());
    add(
      'app_settings.json',
      jsonEncode({for (final s in settings) s.key: s.value}),
    );
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
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

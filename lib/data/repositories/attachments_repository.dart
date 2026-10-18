import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/note_text.dart';
import '../db/app_database.dart';

/// Turns a picked / recorded / shared file into the stored attachment file:
/// audio is copied as is; pictures are shrunk to a viewing copy and a small
/// one for the reminder notification. Returns the duration for audio.
typedef AttachmentImporter =
    Future<({bool ok, int? durationMs})> Function(
      String src,
      String kind,
      File target,
    );

/// Voice clips and pictures of notes. Files sit in the app's private
/// `attachments/` folder, named after the attachment id; rows cascade with
/// their note and [sweep] removes files nobody points to any more.
class AttachmentsRepository {
  AttachmentsRepository(
    this.db, {
    Future<Directory> Function()? dir,
    AttachmentImporter? importer,
    DateTime Function()? clock,
  }) : _dir = dir ?? _defaultDir,
       _importer = importer ?? _copy,
       _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final Future<Directory> Function() _dir;
  final AttachmentImporter _importer;
  final DateTime Function() _clock;

  /// Long side of the small picture shown in a reminder notification.
  static const notificationSide = 720;

  static Future<Directory> _defaultDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'attachments')).create(recursive: true);
  }

  static Future<({bool ok, int? durationMs})> _copy(
    String src,
    String kind,
    File target,
  ) async {
    await File(src).copy(target.path);
    return (ok: true, durationMs: null);
  }

  static String kindOf(String mime) => mime.startsWith('image/')
      ? 'image'
      : mime.startsWith('video/')
      ? 'video'
      : 'audio';

  Future<File> fileOf(NoteAttachment a) async =>
      File(p.join((await _dir()).path, a.file));

  /// The small copy of a picture — or a video's poster frame — used in the
  /// note and in notifications (a picture falls back to itself).
  Future<File> notificationFileOf(NoteAttachment a) async {
    final small = File(
      p.join(
        (await _dir()).path,
        '${p.basenameWithoutExtension(a.file)}_n.jpg',
      ),
    );
    return await small.exists() ? small : fileOf(a);
  }

  /// Attaches the file at [src] to note [noteId]. Null when the file could
  /// not be read.
  Future<NoteAttachment?> add(String noteId, String src, String mime) async {
    final kind = kindOf(mime);
    final id = NoteText.uuid();
    final srcExt = p.extension(src).replaceFirst('.', '').toLowerCase();
    final ext = kind == 'image'
        ? 'jpg'
        : srcExt.isNotEmpty
        ? srcExt
        : (kind == 'video' ? 'mp4' : 'm4a');
    final target = File(p.join((await _dir()).path, '$id.$ext'));
    final ({bool ok, int? durationMs}) imported;
    try {
      imported = await _importer(src, kind, target);
    } on FileSystemException {
      return null;
    }
    if (!imported.ok) return null;
    final now = _clock().millisecondsSinceEpoch;
    final row = NoteAttachment(
      id: id,
      noteId: noteId,
      kind: kind,
      file: p.basename(target.path),
      mime: kind == 'image' ? 'image/jpeg' : mime,
      durationMs: imported.durationMs,
      createdAt: now,
    );
    await db.transaction(() async {
      await db.into(db.noteAttachments).insert(row);
      // Lists sorted by "son düzenlenen" move it up.
      await (db.update(db.notes)..where((n) => n.id.equals(noteId))).write(
        NotesCompanion(updatedAt: Value(now)),
      );
    });
    return row;
  }

  Future<NoteAttachment?> get(String id) => (db.select(
    db.noteAttachments,
  )..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<List<NoteAttachment>> of(String noteId) =>
      (db.select(db.noteAttachments)
            ..where((a) => a.noteId.equals(noteId))
            ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
          .get();

  Stream<List<NoteAttachment>> watch(String noteId) =>
      (db.select(db.noteAttachments)
            ..where((a) => a.noteId.equals(noteId))
            ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
          .watch();

  /// Attachments of several notes at once (reminder notifications).
  Future<Map<String, List<NoteAttachment>>> ofNotes(
    Iterable<String> noteIds,
  ) async {
    final ids = noteIds.toList();
    if (ids.isEmpty) return const {};
    final rows =
        await (db.select(db.noteAttachments)
              ..where((a) => a.noteId.isIn(ids))
              ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
            .get();
    final out = <String, List<NoteAttachment>>{};
    for (final r in rows) {
      (out[r.noteId] ??= []).add(r);
    }
    return out;
  }

  Future<void> remove(NoteAttachment a) async {
    await (db.delete(db.noteAttachments)..where((x) => x.id.equals(a.id))).go();
    await _deleteFiles(a.file);
  }

  Future<void> _deleteFiles(String file) async {
    final dir = (await _dir()).path;
    for (final name in [file, '${p.basenameWithoutExtension(file)}_n.jpg']) {
      final f = File(p.join(dir, name));
      if (await f.exists()) await f.delete();
    }
  }

  /// Deletes files whose attachment row is gone (its note was deleted).
  /// Returns how many files went.
  Future<int> sweep() async {
    final dir = await _dir();
    final keep = {
      for (final a in await db.select(db.noteAttachments).get())
        p.basenameWithoutExtension(a.file),
    };
    var removed = 0;
    await for (final f in dir.list()) {
      if (f is! File) continue;
      final stem = p
          .basenameWithoutExtension(f.path)
          .replaceFirst(RegExp(r'_n$'), '');
      if (!keep.contains(stem)) {
        await f.delete();
        removed++;
      }
    }
    return removed;
  }
}

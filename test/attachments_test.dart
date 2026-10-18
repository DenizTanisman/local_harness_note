import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/io/backup_service.dart';
import 'package:local_harness_not/data/repositories/attachments_repository.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late NotesRepository notes;
  late Directory tmp;
  late AttachmentsRepository repo;

  /// Test importer: copies, and for pictures also writes the small copy.
  Future<({bool ok, int? durationMs})> importer(
    String src,
    String kind,
    File target,
  ) async {
    await File(src).copy(target.path);
    if (kind == 'image') {
      await File(src).copy(
        p.join(
          target.parent.path,
          '${p.basenameWithoutExtension(target.path)}_n.jpg',
        ),
      );
    }
    return (ok: true, durationMs: kind == 'audio' ? 4200 : null);
  }

  AttachmentsRepository repoFor(AppDatabase d, String dir) =>
      AttachmentsRepository(
        d,
        dir: () => Directory(dir).create(recursive: true),
        importer: importer,
      );

  Future<String> source(String name, String content) async {
    final f = File(p.join(tmp.path, 'src', name));
    await f.create(recursive: true);
    await f.writeAsString(content);
    return f.path;
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    notes = NotesRepository(db);
    tmp = await Directory.systemTemp.createTemp('att');
    repo = repoFor(db, p.join(tmp.path, 'attachments'));
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test('a voice clip and a picture attach to a note', () async {
    final id = await notes.create('Annemin sesi #aile');
    await notes.addToReminders(id);
    final clip = await repo.add(
      id,
      await source('ses.ogg', 'ogg'),
      'audio/ogg',
    );
    final pic = await repo.add(
      id,
      await source('foto.png', 'png'),
      'image/png',
    );
    expect(clip!.kind, 'audio');
    expect(clip.file, endsWith('.ogg'));
    expect(clip.durationMs, 4200);
    expect(pic!.kind, 'image');
    expect(pic.file, endsWith('.jpg'));
    expect(pic.mime, 'image/jpeg');
    expect(await (await repo.fileOf(clip)).readAsString(), 'ogg');
    expect(
      p.basename((await repo.notificationFileOf(pic)).path),
      endsWith('_n.jpg'),
    );

    final listed = (await notes.watchNotes().first).single;
    expect(listed.media, {'audio', 'image'});
    final reminder = (await notes.watchReminders().first).single;
    expect(reminder.media, {'audio', 'image'});
    expect((await repo.ofNotes([id]))[id], hasLength(2));
  });

  test('removing an attachment deletes its files', () async {
    final id = await notes.create('foto');
    final pic = await repo.add(id, await source('a.jpg', 'x'), 'image/jpeg');
    final dir = Directory(p.join(tmp.path, 'attachments'));
    expect(await dir.list().length, 2);
    await repo.remove(pic!);
    expect(await dir.list().length, 0);
    expect(await repo.of(id), isEmpty);
  });

  test('deleting the note drops rows; sweep removes the files', () async {
    final id = await notes.create('geçici');
    await repo.add(id, await source('a.m4a', 'x'), 'audio/mp4');
    final keep = await notes.create('kalıcı');
    await repo.add(keep, await source('b.m4a', 'y'), 'audio/mp4');
    await notes.delete(id);
    expect(await db.select(db.noteAttachments).get(), hasLength(1));
    expect(await repo.sweep(), 1);
    expect(await repo.sweep(), 0);
    expect(
      await (await repo.fileOf((await repo.of(keep)).single)).exists(),
      isTrue,
    );
  });

  test('backup carries attachments and their files', () async {
    final id = await notes.create('yedek #ses');
    await repo.add(id, await source('s.ogg', 'SES'), 'audio/ogg');
    await repo.add(id, await source('g.jpg', 'GORSEL'), 'image/jpeg');
    final zip = await BackupService.decryptBackup(
      await BackupService(db, attachments: repo).createEncryptedBackup('pw'),
      'pw',
    );

    final fresh = AppDatabase(NativeDatabase.memory());
    final freshRepo = repoFor(fresh, p.join(tmp.path, 'restored'));
    await BackupService(fresh, attachments: freshRepo).restoreZip(zip);
    final restored = await freshRepo.of(id);
    expect(restored.map((a) => a.kind), ['audio', 'image']);
    expect(
      await (await freshRepo.fileOf(restored.first)).readAsString(),
      'SES',
    );
    expect(
      await (await freshRepo.notificationFileOf(restored.last)).readAsString(),
      'GORSEL',
    );
    await fresh.close();
  });

  test('a video attaches as video and stays out of backups', () async {
    expect(AttachmentsRepository.kindOf('video/mp4'), 'video');
    final id = await notes.create('video notu');
    final video = await repo.add(
      id,
      await source('klip.mp4', 'MP4'),
      'video/mp4',
    );
    expect(video!.kind, 'video');
    expect(video.file, endsWith('.mp4'));
    expect((await notes.watchNotes().first).single.media, {'video'});

    final zip = await BackupService.decryptBackup(
      await BackupService(db, attachments: repo).createEncryptedBackup('pw'),
      'pw',
    );
    final fresh = AppDatabase(NativeDatabase.memory());
    final freshRepo = repoFor(fresh, p.join(tmp.path, 'restored-v'));
    await BackupService(fresh, attachments: freshRepo).restoreZip(zip);
    expect(await freshRepo.of(id), isEmpty);
    expect(await NotesRepository(fresh).getNote(id), isNotNull);
    await fresh.close();
  });
}

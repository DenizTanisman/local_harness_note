import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/attachments_repository.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';
import 'package:local_harness_not/features/relay/mcp_tools.dart';
import 'package:path/path.dart' as p;

/// create_note as the Mac's /inbox sends it: a clip queued on the relay and
/// "put it on the reminder list".
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late Directory tmp;
  late AttachmentsRepository files;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('inbox');
    files = AttachmentsRepository(
      db,
      dir: () => Directory(p.join(tmp.path, 'att')).create(recursive: true),
    );
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  McpTools tools(BlobFetcher fetch) => McpTools(
    db,
    fetchBlob: fetch,
    attachments: files,
    tempDir: () async => tmp,
  );

  const args = {
    'text': 'Değişim\n\nmetin\n\nÖzet: kısa',
    'add_to_reminders': true,
    'audio': {'blob': 'b1', 'name': 'konusma.mp3', 'mime': 'audio/mpeg'},
  };

  test('note + clip + reminder list', () async {
    final r = await tools(
      (id) async => id == 'b1' ? [1, 2, 3] : throw StateError(id),
    ).execute('create_note', args, reqId: 'q1');
    final id = r['id']! as String;
    expect(r['audio'], true);
    expect(r['in_reminders'], true);
    final clip = (await files.of(id)).single;
    expect(clip.kind, 'audio');
    expect(await (await files.fileOf(clip)).readAsBytes(), [1, 2, 3]);
    expect((await NotesRepository(db).reminderNotes()).single.id, id);
    // The temp copy is gone.
    expect(tmp.listSync().whereType<File>(), isEmpty);
  });

  test('clip not reachable → nothing written, call stays queued', () async {
    final t = tools((_) async => throw const SocketException('offline'));
    await expectLater(
      t.execute('create_note', args, reqId: 'q2'),
      throwsA(isA<RetryLater>()),
    );
    expect(await db.select(db.notes).get(), isEmpty);
    // Next wake: it works and is applied once.
    final ok = tools((_) async => [9]);
    await ok.execute('create_note', args, reqId: 'q2');
    await ok.execute('create_note', args, reqId: 'q2');
    expect(await db.select(db.notes).get(), hasLength(1));
  });

  test('clip already gone → the note still comes', () async {
    final r = await tools(
      (_) async => const [],
    ).execute('create_note', args, reqId: 'q3');
    expect(r.containsKey('audio'), isFalse);
    expect(await files.of(r['id']! as String), isEmpty);
  });
}

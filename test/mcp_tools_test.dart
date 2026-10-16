import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/core/hub_snapshot_publisher.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/io/backup_service.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';
import 'package:local_harness_not/features/relay/mcp_tools.dart';
import 'package:local_harness_not/features/relay/relay_client.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late NotesRepository repo;
  late McpTools tools;
  var n = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = NotesRepository(db);
    tools = McpTools(db);
  });
  tearDown(() => db.close());

  Future<Map<String, Object?>> call(String tool, Map<String, Object?> args) =>
      tools.execute(tool, args, reqId: 'r${n++}');

  group('MCP tools', () {
    test('search, get, list_recent', () async {
      final id = await repo.create('Kitap fikri\nIşık üzerine deneme #yazı');
      await repo.create('Market listesi');
      final found = await call('search_notes', {'query': 'isik'});
      final results = found['results']! as List;
      expect(results, hasLength(1));
      expect((results.single as Map)['id'], id);
      expect((results.single as Map)['title'], 'Kitap fikri');

      final note = await call('get_note', {'id': id});
      expect(note['body'], contains('Işık'));
      expect(note['tags'], ['yazı']);
      expect(note['in_reminders'], false);

      final recent = await call('list_recent', {'days': 1, 'limit': 1});
      expect(recent['results'], hasLength(1));
      expect(recent['next_cursor'], '1');
    });

    test('private notes are invisible to every tool', () async {
      final id = await repo.create('gizli şifre notu', isPrivate: true);
      expect(
        (await call('search_notes', {'query': 'gizli'}))['results'],
        isEmpty,
      );
      expect((await call('list_recent', {}))['results'], isEmpty);
      for (final tool in [
        'get_note',
        'append_to_note',
        'archive_note',
        'add_to_reminders',
      ]) {
        await expectLater(
          call(tool, {'id': id, 'text': 'x'}),
          throwsA(isA<ToolError>()),
          reason: tool,
        );
      }
      expect((await repo.getNote(id))!.body, 'gizli şifre notu');
    });

    test('create / append / archive / add_to_reminders', () async {
      final created = await call('create_note', {'text': 'Claude notu #ai'});
      final id = created['id']! as String;
      expect((await repo.getNote(id))!.source, 'claude');
      await call('append_to_note', {'id': id, 'text': 'ek satır'});
      expect((await repo.getNote(id))!.body, 'Claude notu #ai\n\nek satır');
      await call('add_to_reminders', {'id': id});
      expect((await repo.reminderNotes()).single.id, id);
      await call('archive_note', {'id': id});
      expect((await repo.getNote(id))!.status, 'archived');
      expect(await repo.reminderNotes(), isEmpty);
    });

    test('a write delivered twice is applied once', () async {
      await tools.execute('create_note', {'text': 'bir kez'}, reqId: 'same');
      final again = await tools.execute('create_note', {
        'text': 'bir kez',
      }, reqId: 'same');
      expect(again['duplicate'], true);
      expect(await repo.search(query: 'bir kez'), hasLength(1));
    });

    test('no delete tool; unknown tools and bad ids fail cleanly', () async {
      await expectLater(
        call('delete_note', {'id': 'x'}),
        throwsA(isA<ToolError>()),
      );
      await expectLater(
        call('get_note', {'id': 'yok'}),
        throwsA(isA<ToolError>()),
      );
      await expectLater(
        call('create_note', {'text': '  '}),
        throwsA(isA<ToolError>()),
      );
    });
  });

  group('pairing code', () {
    test('parses and validates', () {
      final config = RelayConfig.parse(
        jsonEncode({
          'url': 'https://not-relay.example.workers.dev/',
          'secret': '0123456789abcdef0123',
          'firebase': {
            'apiKey': 'k',
            'appId': '1:2:android:3',
            'messagingSenderId': '2',
            'projectId': 'p',
          },
        }),
      );
      expect(config.url, 'https://not-relay.example.workers.dev');
      expect(() => RelayConfig.parse('{}'), throwsFormatException);
      expect(() => RelayConfig.parse('nope'), throwsFormatException);
    });
  });

  group('hub snapshot v2', () {
    test('counts and next reminder; private title hidden', () async {
      final now = DateTime(2026, 10, 16, 9);
      final a = await repo.create('Gizli plan', isPrivate: true);
      await repo.create('Açık not');
      await repo.addToReminders(a);
      final snap = await buildHubSnapshot(db, now: now);
      expect(snap['schema'], 2);
      final data = snap['data']! as Map;
      expect(data['notes'], {'total': 2, 'inbox': 2});
      expect(data['nextReminder'], {
        'title': '🔒',
        'at': '2026-10-16T14:00:00',
      });
      expect(jsonEncode(snap), isNot(contains('Gizli plan')));
    });
  });

  group('backup', () {
    test('zip round-trips notes, versions and reminders', () async {
      final a = await repo.create('yedeklenecek #b');
      await repo.replaceBody(a, 'yeni hali #b', reason: 'gemma');
      await repo.addToReminders(a);
      final service = BackupService(db);
      final encrypted = await service.createEncryptedBackup('pw');
      final zip = await BackupService.decryptBackup(encrypted, 'pw');
      expect(
        ZipDecoder().decodeBytes(zip).files.map((f) => f.name),
        containsAll(['notes.json', 'note_versions.json', 'reminders.json']),
      );

      final fresh = AppDatabase(NativeDatabase.memory());
      final restored = await BackupService(fresh).restoreZip(zip);
      expect(restored, 1);
      final freshRepo = NotesRepository(fresh);
      expect((await freshRepo.getNote(a))!.body, 'yeni hali #b');
      expect(await freshRepo.search(query: 'yeni'), hasLength(1));
      expect(await freshRepo.tagsOf(a), ['b']);
      expect((await freshRepo.reminderNotes()).single.id, a);
      expect(
        (await freshRepo.watchVersions(a).first).single.body,
        'yedeklenecek #b',
      );
      await expectLater(
        BackupService.decryptBackup(encrypted, 'yanlış'),
        throwsA(anything),
      );
      expect(encrypted, isA<Uint8List>());
      await fresh.close();
    });
  });
}

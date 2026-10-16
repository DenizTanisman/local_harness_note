import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/core/note_text.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';
import 'package:local_harness_not/features/reminders/reminder_planner.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late NotesRepository repo;
  var now = DateTime(2026, 10, 16, 9);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 10, 16, 9);
    repo = NotesRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  Future<String> note(String body, {bool private = false}) async {
    final id = await repo.create(body, isPrivate: private);
    now = now.add(const Duration(minutes: 1));
    return id;
  }

  group('NoteText', () {
    test('folds Turkish letters for search', () {
      expect(NoteText.fold('IŞIK İstanbul ÇĞÖÜ'), 'isik istanbul cgou');
      expect(NoteText.fold('ışık').length, 'ışık'.length);
    });

    test('extracts tags, ignoring url fragments', () {
      expect(
        NoteText.tags('Fikir #Proje ve #iş-planı\nhttps://x.com/#bölüm #proje'),
        ['proje', 'iş-planı'],
      );
    });

    test('title and rest', () {
      expect(NoteText.title('\n  Başlık  \ngövde'), 'Başlık');
      expect(NoteText.rest('\n  Başlık  \ngövde\nikinci'), 'gövde\nikinci');
      // Merged notes: the date separator is not the title.
      const merged = '— 16 Eki 2026 —\nFikir: tema\nayrıntı';
      expect(NoteText.title(merged), 'Fikir: tema');
      expect(NoteText.rest(merged), 'ayrıntı');
    });

    test('finds the #tag under the cursor', () {
      const text = 'Plan #fi bitti';
      expect(NoteText.tagAt(text, 8), (start: 5, end: 8, prefix: 'fi'));
      expect(NoteText.tagAt(text, 6), (start: 5, end: 8, prefix: ''));
      expect(NoteText.tagAt(text, 3), isNull); // not in a tag
      expect(NoteText.tagAt('a#b', 3), isNull); // # inside a word
      expect(NoteText.tagAt('#', 1), (start: 0, end: 1, prefix: ''));
    });

    test('inserting a suggestion completes the word and adds a space', () {
      const text = 'Plan #fi';
      final at = NoteText.tagAt(text, text.length)!;
      expect(NoteText.insertTag(text, at, 'fikir'), (
        text: 'Plan #fikir ',
        cursor: 12,
      ));
      // Already followed by a space: no double space, cursor after it.
      const mid = 'x #fi y';
      final at2 = NoteText.tagAt(mid, 5)!;
      expect(NoteText.insertTag(mid, at2, 'fikir'), (
        text: 'x #fikir y',
        cursor: 9,
      ));
    });

    test('suggestions keep most-used order, Turkish-insensitive', () {
      const byUse = ['iş', 'fikir', 'film', 'kitap'];
      expect(NoteText.suggestTags(byUse, ''), byUse);
      expect(NoteText.suggestTags(byUse, 'fi'), ['fikir', 'film']);
      expect(NoteText.suggestTags(byUse, 'is'), ['iş']);
      expect(NoteText.suggestTags(byUse, 'fikir'), isEmpty);
    });

    test('uuid v4 shape', () {
      expect(
        NoteText.uuid(),
        matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab]')),
      );
    });
  });

  group('search', () {
    test('Turkish-insensitive prefix search', () async {
      final a = await note('Işık ve gölge üzerine bir fikir');
      await note('Alışveriş listesi');
      final hits = await repo.search(query: 'isik golg');
      expect(hits.map((h) => h.id), [a]);
      expect(hits.single.snippet, contains('Işık'));
    });

    test('tag filter from chip and from #word in the query', () async {
      final a = await note('Uygulama fikri #proje');
      await note('Başka bir #proje notu');
      await note('Etiketsiz uygulama');
      expect((await repo.search(query: 'uygulama #proje')).map((h) => h.id), [
        a,
      ]);
      expect(await repo.search(tag: 'proje'), hasLength(2));
    });

    test('private notes are hidden unless asked for', () async {
      await note('gizli plan', private: true);
      expect(await repo.search(query: 'plan'), isEmpty);
      expect(
        await repo.search(query: 'plan', includePrivate: true),
        hasLength(1),
      );
    });

    test('archived notes only with includeArchived', () async {
      final a = await note('eski fikir');
      await repo.archive(a);
      expect(await repo.search(query: 'fikir'), isEmpty);
      expect(
        await repo.search(query: 'fikir', includeArchived: true),
        hasLength(1),
      );
    });

    test('editing re-indexes body and tags', () async {
      final a = await note('ilk metin #a');
      await repo.updateBody(a, 'yeni içerik #b');
      expect(await repo.search(query: 'ilk'), isEmpty);
      expect(await repo.search(query: 'icerik'), hasLength(1));
      expect(await repo.tagsOf(a), ['b']);
    });

    test('10k notes search stays fast', () async {
      await db.transaction(() async {
        for (var i = 0; i < 10000; i++) {
          await repo.create(
            'not numarası $i hakkında rastgele metin #t${i % 50}',
          );
        }
      });
      await repo.create('aranan özel kelime zümrüt');
      final sw = Stopwatch()..start();
      final hits = await repo.search(query: 'zumrut');
      sw.stop();
      expect(hits, hasLength(1));
      expect(sw.elapsedMilliseconds, lessThan(100));
    });

    test('tag counts: most used first, archive included', () async {
      await note('a #fikir #kitap');
      await note('b #fikir');
      final c = await note('c #fikir #iş');
      await repo.archive(c);
      expect(await repo.watchTagCounts().first, [
        (tag: 'fikir', count: 3),
        (tag: 'iş', count: 1),
        (tag: 'kitap', count: 1),
      ]);
    });

    test('list stream updates on writes', () async {
      final stream = repo.watchNotes();
      final a = await note('birinci');
      expect((await stream.first).map((n) => n.id), [a]);
    });
  });

  group('merge', () {
    test('oldest first with date lines; originals archived', () async {
      final a = await note('ilk parça #x');
      final b = await note('ikinci parça #y', private: true);
      final undo = await repo.merge([b, a]);
      final merged = (await repo.getNote(undo.mergedId))!;
      expect(
        merged.body,
        '— 16 Eki 2026 —\nilk parça #x\n\n'
        '— 16 Eki 2026 —\nikinci parça #y',
      );
      expect(merged.isPrivate, isTrue);
      expect(merged.source, 'merge');
      expect(await repo.tagsOf(merged.id), ['x', 'y']);
      final old = (await repo.getNote(a))!;
      expect(old.status, 'archived');
      expect(old.mergedInto, merged.id);
    });

    test('takes the earliest reminder slot; undo restores all', () async {
      final a = await note('a');
      final b = await note('b');
      final c = await note('c');
      final d = await note('d');
      for (final id in [a, b, c, d]) {
        await repo.addToReminders(id);
      }
      final before = await repo.reminderNotes();
      final undo = await repo.merge([b, d]);
      final after = (await repo.reminderNotes()).map((n) => n.id).toList();
      expect(after, [a, undo.mergedId, c]);

      await repo.undoMerge(undo);
      expect(await repo.getNote(undo.mergedId), isNull);
      expect((await repo.reminderNotes()).map((n) => n.id), [
        for (final n in before) n.id,
      ]);
      expect((await repo.getNote(b))!.status, 'inbox');
      expect((await repo.getNote(b))!.mergedInto, isNull);
      expect(await repo.search(query: 'b'), isNotEmpty);
    });
  });

  group('versions', () {
    test('replaceBody keeps the old body; revert swaps back', () async {
      final a = await note('ham metin');
      await repo.replaceBody(a, 'toparlanmış metin', reason: 'gemma');
      expect((await repo.getNote(a))!.body, 'toparlanmış metin');
      final versions = await repo.watchVersions(a).first;
      expect(versions.single.body, 'ham metin');
      expect(versions.single.reason, 'gemma');
      await repo.revertTo(versions.single);
      expect((await repo.getNote(a))!.body, 'ham metin');
      expect(await repo.watchVersions(a).first, hasLength(2));
    });
  });

  group('reminder list', () {
    test('archive removes from reminders; removing the next item moves '
        'the cursor to the following one', () async {
      final a = await note('a');
      final b = await note('b');
      final c = await note('c');
      for (final id in [a, b, c]) {
        await repo.addToReminders(id);
      }
      await repo.saveCursor(ReminderCursor(b, null));
      await repo.archive(b);
      expect((await repo.reminderNotes()).map((n) => n.id), [a, c]);
      expect((await repo.loadCursor()).noteId, c);
    });

    test('reorder', () async {
      final a = await note('a');
      final b = await note('b');
      await repo.addToReminders(a);
      await repo.addToReminders(b);
      await repo.addToReminders(a); // no duplicate
      await repo.reorderReminders([b, a]);
      expect((await repo.reminderNotes()).map((n) => n.id), [b, a]);
    });
  });

  group('archive auto-delete', () {
    test('archived notes go after 45 days, not before; unarchive stops '
        'the clock', () async {
      final a = await note('eski arşiv');
      final b = await note('geri alınan');
      final c = await note('gelen kutusunda');
      await repo.archive(a);
      await repo.archive(b);
      await repo.addToReminders(c);
      final archived = (await repo.getNote(a))!;
      expect(
        NotesRepository.deletesOn(archived),
        DateTime.fromMillisecondsSinceEpoch(
          archived.archivedAt!,
        ).add(const Duration(days: 45)),
      );
      await repo.unarchive(b);
      expect((await repo.getNote(b))!.archivedAt, isNull);

      now = now.add(const Duration(days: 44));
      expect(await repo.purgeArchived(), 0);
      now = now.add(const Duration(days: 2));
      expect(await repo.purgeArchived(), 1);
      expect(await repo.getNote(a), isNull);
      expect(await repo.search(query: 'eski', includeArchived: true), isEmpty);
      expect(await repo.getNote(b), isNotNull);
      expect(await repo.getNote(c), isNotNull);
    });

    test('merged originals start the clock too', () async {
      final a = await note('parça bir');
      final b = await note('parça iki');
      await repo.merge([a, b]);
      expect((await repo.getNote(a))!.archivedAt, isNotNull);
    });
  });

  test('v2 → v3 upgrade adds archived_at and starts the clock for notes '
      'already archived', () async {
    final raw = NativeDatabase.memory(
      setup: (d) {
        d.execute(
          'CREATE TABLE notes (id TEXT NOT NULL PRIMARY KEY, body TEXT NOT NULL, '
          "status TEXT NOT NULL DEFAULT 'inbox', is_private INTEGER NOT NULL "
          "DEFAULT 0, source TEXT NOT NULL DEFAULT 'phone', merged_into TEXT, "
          'created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
        );
        d.execute(
          "INSERT INTO notes VALUES ('a', 'x', 'archived', 0, 'phone', NULL, 1, 500)",
        );
        d.execute(
          "INSERT INTO notes VALUES ('b', 'y', 'inbox', 0, 'phone', NULL, 1, 600)",
        );
        d.execute('PRAGMA user_version = 2');
      },
    );
    final upgraded = AppDatabase(raw);
    final rows = await upgraded.select(upgraded.notes).get();
    final byId = {for (final r in rows) r.id: r};
    expect(byId['a']!.archivedAt, 500);
    expect(byId['b']!.archivedAt, isNull);
    await upgraded.close();
  });

  test('v1 → v2 upgrade drops the check-in tables', () async {
    final raw = NativeDatabase.memory(
      setup: (d) {
        d.execute('CREATE TABLE metrics (id INTEGER PRIMARY KEY)');
        d.execute('CREATE TABLE entries (id INTEGER PRIMARY KEY)');
        d.execute(
          'CREATE TABLE app_settings (key TEXT PRIMARY KEY, value TEXT)',
        );
        d.execute("INSERT INTO app_settings VALUES ('morning_time', '08:00')");
        d.execute("INSERT INTO app_settings VALUES ('flag_secure', 'true')");
        d.execute('PRAGMA user_version = 1');
      },
    );
    final upgraded = AppDatabase(raw);
    final tables = await upgraded
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = tables.map((r) => r.read<String>('name')).toSet();
    expect(names, containsAll(['notes', 'reminders', 'notes_fts']));
    expect(names, isNot(contains('metrics')));
    final settings = await upgraded.select(upgraded.appSettings).get();
    expect(settings.map((s) => s.key), ['flag_secure']);
    await NotesRepository(upgraded).create('çalışıyor');
    expect(
      await NotesRepository(upgraded).search(query: 'calis'),
      hasLength(1),
    );
    await upgraded.close();
  });
}

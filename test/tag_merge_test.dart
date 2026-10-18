import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/db/database_provider.dart';
import 'package:local_harness_not/data/repositories/attachments_repository.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';
import 'package:local_harness_not/features/notes/attachments_view.dart';
import 'package:local_harness_not/features/notes/note_editor_page.dart';
import 'package:local_harness_not/features/notes/tag_notes_page.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late NotesRepository repo;
  late Directory tmp;
  var now = DateTime(2026, 10, 19, 9);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 10, 19, 9);
    repo = NotesRepository(db, clock: () => now);
    tmp = await Directory.systemTemp.createTemp('tagmerge');
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  Future<String> note(String body) async {
    final id = await repo.create(body);
    now = now.add(const Duration(minutes: 1));
    return id;
  }

  Widget app(Widget home) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      attachmentsRepositoryProvider.overrideWithValue(
        AttachmentsRepository(db, dir: () async => tmp),
      ),
    ],
    child: MaterialApp(home: home),
  );

  /// Real DB futures finish, frames advance.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  group('merge under a tag', () {
    test('adds the tag when the merged text lacks it, once', () async {
      final a = await note('bir');
      final b = await note('iki #sohbet');
      final undo = await repo.merge([a, b], tag: 'sohbet');
      final merged = (await repo.getNote(undo.mergedId))!;
      expect(RegExp('#sohbet').allMatches(merged.body), hasLength(1));
      final c = await note('üç');
      final d = await note('dört');
      final other = await repo.merge([c, d], tag: 'sohbet');
      expect((await repo.getNote(other.mergedId))!.body, endsWith('#sohbet'));
      expect((await repo.getNote(c))!.status, 'archived');
    });
  });

  testWidgets('tag page lists the tag, last edited first, and merges', (
    tester,
  ) async {
    late String from, older, newest, other;
    await tester.runAsync(() async {
      older = await note('Eski mesaj #sohbet');
      from = await note('Bu not #sohbet');
      newest = await note('Yeni mesaj #sohbet-gece');
      other = await note('Başka konu #iş');
    });
    await tester.pumpWidget(app(TagNotesPage(tag: 'sohbet', fromNoteId: from)));
    await settle(tester);

    // Sub-tags included, other tags not; newest first.
    final titles = tester
        .widgetList<Text>(find.textContaining('mesaj'))
        .map((t) => t.data)
        .toList();
    expect(titles.first, contains('Yeni'));
    expect(find.text('Başka konu #iş'), findsNothing);
    expect(find.text('Bu not'), findsOneWidget);

    await tester.tap(find.byKey(Key('merge-$older')));
    await tester.tap(find.byKey(Key('merge-$newest')));
    await tester.pump();
    expect(find.text('3 notu birleştir · #sohbet'), findsOneWidget);
    await tester.tap(find.byKey(const Key('tag-merge')));
    await settle(tester);

    await tester.runAsync(() async {
      for (final id in [from, older, newest]) {
        expect((await repo.getNote(id))!.status, 'archived');
      }
      expect((await repo.getNote(other))!.status, 'inbox');
      final inbox = await repo.watchNotes().first;
      final merged = inbox.firstWhere((n) => n.note.source == 'merge');
      expect(merged.note.body, contains('Bu not'));
      expect(merged.note.body, contains('Eski mesaj'));
      expect(merged.tags, contains('sohbet'));
    });
  });

  group('erasing a note completely', () {
    Future<String> openAndErase(WidgetTester tester) async {
      late String id;
      await tester.runAsync(() async => id = await note('Silinecek\nmetin'));
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NoteEditorPage(noteId: id)),
              ),
              child: const Text('aç'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('aç'));
      await settle(tester);
      await tester.tap(find.byKey(const Key('editor-view')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('editor-text')), '');
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
      expect(find.text('Bu notu silmek istiyor musun?'), findsOneWidget);
      return id;
    }

    testWidgets('asks, then archives it as it was', (tester) async {
      final id = await openAndErase(tester);
      await tester.tap(find.byKey(const Key('emptied-archive')));
      await settle(tester);
      expect(find.text('aç'), findsOneWidget); // left the note
      await tester.runAsync(() async {
        final n = (await repo.getNote(id))!;
        expect(n.status, 'archived');
        expect(n.body, 'Silinecek\nmetin');
      });
    });

    testWidgets('Vazgeç brings the text back and stays', (tester) async {
      final id = await openAndErase(tester);
      await tester.tap(find.text('Vazgeç'));
      await settle(tester);
      expect(find.text('aç'), findsNothing);
      final field = tester.widget<TextField>(
        find.byKey(const Key('editor-text')),
      );
      expect(field.controller!.text, 'Silinecek\nmetin');
      await tester.runAsync(() async {
        expect((await repo.getNote(id))!.status, 'inbox');
      });
      // Leave the editor so its save / keyboard timers run out.
      await tester.pumpWidget(const SizedBox());
      await settle(tester);
    });
  });
}

import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/db/database_provider.dart';
import 'package:local_harness_not/data/repositories/notes_repository.dart';
import 'package:local_harness_not/features/gemma/gemma_page.dart';
import 'package:local_harness_not/features/gemma/gemma_service.dart';
import 'package:local_harness_not/features/notes/notes_providers.dart';

/// Gemma stand-in: tokens are pushed by the test.
class FakeGemma extends GemmaService {
  StreamController<String>? tokens;
  String? lastPrompt;
  bool stopped = false;

  @override
  Future<void> refresh() async => status.value = const GemmaReady();

  @override
  Stream<String> generate(String prompt) {
    lastPrompt = prompt;
    tokens = StreamController<String>();
    return tokens!.stream;
  }

  @override
  Future<void> stop() async {
    stopped = true;
    await tokens?.close();
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late FakeGemma gemma;
  late String noteId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    gemma = FakeGemma();
    noteId = await NotesRepository(db).create('dağınık ham not');
  });
  tearDown(() => db.close());

  /// Lets real DB futures finish and frames advance (a spinner never
  /// settles, so pumpAndSettle is not an option while Gemma runs).
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          gemmaServiceProvider.overrideWithValue(gemma),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GemmaPage(noteId: noteId)),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);
  }

  testWidgets('prompt carries the note; back while running asks first, '
      '"Kal" stays, "Çık" stops Gemma', (tester) async {
    await open(tester);
    expect(gemma.lastPrompt, contains('dağınık ham not'));
    expect(gemma.lastPrompt, contains('toparla'));
    gemma.tokens!.add('Topar');
    await tester.pump();
    expect(find.textContaining('Topar'), findsOneWidget);

    // System back while Gemma writes → dialog.
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('Emin misin?'), findsOneWidget);
    expect(find.textContaining('hâlâ çalışıyor'), findsOneWidget);
    await tester.tap(find.byKey(const Key('gemma-stay')));
    await settle(tester);
    expect(find.byType(GemmaPage), findsOneWidget);
    expect(gemma.stopped, isFalse);

    await tester.binding.handlePopRoute();
    await settle(tester);
    await tester.tap(find.byKey(const Key('gemma-leave')));
    await settle(tester);
    expect(find.byType(GemmaPage), findsNothing);
    expect(gemma.stopped, isTrue);
    expect(
      (await NotesRepository(db).getNote(noteId))!.body,
      'dağınık ham not',
    );
  });

  testWidgets('finished but unaccepted output also asks; editing then '
      'Onayla replaces the note and keeps the old text as a version', (
    tester,
  ) async {
    await open(tester);
    gemma.tokens!.add('Toparlanmış ');
    gemma.tokens!.add('not');
    await gemma.tokens!.close();
    await settle(tester);

    await tester.tap(find.byTooltip('Vazgeç'));
    await settle(tester);
    expect(find.textContaining('onaylamadın'), findsOneWidget);
    await tester.tap(find.byKey(const Key('gemma-stay')));
    await settle(tester);

    await tester.enterText(
      find.byKey(const Key('gemma-output')),
      'Elle düzeltilmiş not',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('gemma-accept')));
    await settle(tester);
    expect(find.byType(GemmaPage), findsNothing);

    final repo = NotesRepository(db);
    late String body;
    late List<NoteVersion> versions;
    await tester.runAsync(() async {
      body = (await repo.getNote(noteId))!.body;
      versions = await repo.watchVersions(noteId).first;
    });
    expect(body, 'Elle düzeltilmiş not');
    expect(versions.single.body, 'dağınık ham not');
  });

  test('custom prompt without the slot still gets the note', () {
    expect(GemmaService.buildPrompt('Özetle:', 'metin'), 'Özetle:\n\nmetin');
    expect(GemmaService.buildPrompt(null, 'metin'), contains('NOT:\nmetin'));
  });
}

import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/db/database_provider.dart';
import 'package:local_harness_not/data/repositories/entry_repository.dart';
import 'package:local_harness_not/features/home/home_page.dart';
import 'package:local_harness_not/features/home/home_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 2 acceptance (UI level): drop-onto-card grouping with confirm,
/// group-into-group rejection, star flow dialog.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget app() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      debounceDurationProvider.overrideWithValue(Duration.zero),
    ],
    child: const MaterialApp(home: HomePage()),
  );

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  Future<Metric> byKey(String key) =>
      (db.select(db.metrics)..where((m) => m.key.equals(key))).getSingle();

  /// Long-press drag [from] onto [to] and release.
  Future<void> longPressDrag(
    WidgetTester tester,
    Finder from,
    Finder to,
  ) async {
    final gesture = await tester.startGesture(tester.getCenter(from));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(to), timeStamp: kLongPressTimeout);
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('dropping a card onto another groups it after confirm', (
    tester,
  ) async {
    await pumpHome(tester);

    await longPressDrag(tester, find.text('Water'), find.text('Sport'));
    expect(find.text('Make Water a sub-item of Sport?'), findsOneWidget);

    await tester.tap(find.text('Group'));
    await tester.pumpAndSettle();

    final water = await byKey('water');
    final sport = await byKey('sport');
    expect(water.parentId, sport.id);
    expect(sport.inputType, 'composite');

    // Water is no longer a top-level card; it renders as a chip in Sport.
    expect(find.widgetWithText(FilterChip, 'Water'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('grouping a group into a card is rejected', (tester) async {
    await pumpHome(tester);

    await longPressDrag(tester, find.text('Development'), find.text('Sport'));
    expect(find.text('Make Development a sub-item of Sport?'), findsNothing);
    expect(find.textContaining('max 2 levels'), findsOneWidget);

    final dev = await byKey('development');
    expect(dev.parentId, isNull);
    await closeApp(tester);
  });

  testWidgets('star toggle only appears on user-added metrics', (tester) async {
    await pumpHome(tester);
    // Core metrics (e.g. Software) are fixed on the heatmap → no star button.
    final softwareCard = find
        .ancestor(of: find.text('Software'), matching: find.byType(Card))
        .first;
    expect(
      find.descendant(of: softwareCard, matching: find.byType(IconButton)),
      findsNothing,
      reason: 'core metric shows no star toggle',
    );
    await closeApp(tester);
  });

  testWidgets('star tap asks for label and stars a user-added metric', (
    tester,
  ) async {
    await EntryRepository(db).addMetric(title: 'My Metric', inputType: 'text');
    await pumpHome(tester);

    final card = find
        .ancestor(of: find.text('My Metric'), matching: find.byType(Card))
        .first;
    final starButton = find
        .descendant(of: card, matching: find.byType(IconButton))
        .first;
    await tester.tap(starButton);
    await tester.pumpAndSettle();
    expect(find.text('Add to heatmap'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'My Extra Stuff',
    );
    await tester.tap(find.text('Star'));
    await tester.pumpAndSettle();

    final metric = await (db.select(
      db.metrics,
    )..where((m) => m.title.equals('My Metric'))).getSingle();
    expect(metric.isStarred, isTrue);
    expect(metric.heatmapLabel, 'My Extra', reason: 'label capped at 2 words');
    await closeApp(tester);
  });
}

import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/features/home/home_page.dart';
import 'package:daily_tracker/features/home/home_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 1 acceptance: enter → close → reopen keeps values; no duplicate
/// rows for the same day; ADD-created checkbox metric works.
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

  // Disposing the ProviderScope makes drift schedule zero-duration timers
  // (StreamQueryStore.markAsClosed); flush them so the test ends cleanly.
  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    // Advance the fake clock so those zero-duration timers actually fire.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> pumpHome(WidgetTester tester) async {
    // Tall viewport so every card is laid out — the assertions below are
    // about data flow, not scrolling.
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  Finder cardOf(String title) =>
      find.ancestor(of: find.text(title), matching: find.byType(Card)).first;

  testWidgets('renders all top-level cards', (tester) async {
    await pumpHome(tester);
    for (final title in [
      'Software',
      'Development',
      'Money',
      'Extra',
      'Instagram',
      'Sport',
      'Brushing',
      'Waste',
      'Water',
    ]) {
      expect(find.text(title), findsWidgets, reason: title);
    }
    // Children are not top-level cards, but appear as composite chips.
    expect(find.text('Marketing'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('int entry persists across reopen without duplicating', (
    tester,
  ) async {
    await pumpHome(tester);

    final waterField = find.descendant(
      of: cardOf('Water'),
      matching: find.byType(TextField),
    );
    await tester.enterText(waterField, '2.5');
    await tester.pumpAndSettle();
    await tester.enterText(waterField, '3');
    await tester.pumpAndSettle();

    // Simulate close → reopen: fresh widget tree, same database.
    await closeApp(tester);
    await pumpHome(tester);

    final reopened = tester.widget<TextField>(
      find.descendant(of: cardOf('Water'), matching: find.byType(TextField)),
    );
    expect(reopened.controller!.text, '3');

    final water = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('water'))).getSingle();
    final rows = await (db.select(
      db.entries,
    )..where((e) => e.metricId.equals(water.id))).get();
    expect(rows, hasLength(1), reason: 'UNIQUE upsert must not duplicate');
    expect(rows.single.numValue, 3);
    await closeApp(tester);
  });

  testWidgets('int_text reveals description only when number > 0', (
    tester,
  ) async {
    await pumpHome(tester);

    Finder sportFields() =>
        find.descendant(of: cardOf('Sport'), matching: find.byType(TextField));
    expect(sportFields(), findsOneWidget, reason: 'no text field at 0');

    await tester.enterText(sportFields().first, '45');
    await tester.pumpAndSettle();
    expect(sportFields(), findsNWidgets(2));

    await tester.enterText(sportFields().last, 'Leg day');
    await tester.pumpAndSettle();

    await closeApp(tester);
    await pumpHome(tester);

    final sport = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('sport'))).getSingle();
    final entry = await (db.select(
      db.entries,
    )..where((e) => e.metricId.equals(sport.id))).getSingle();
    expect(entry.numValue, 45);
    expect(entry.textValue, 'Leg day');
    await closeApp(tester);
  });

  testWidgets('checkbox selections persist', (tester) async {
    await pumpHome(tester);

    await tester.ensureVisible(find.text('Morning'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Morning'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evening'));
    await tester.pumpAndSettle();

    await closeApp(tester);
    await pumpHome(tester);
    await tester.ensureVisible(find.text('Morning'));
    await tester.pumpAndSettle();

    bool checked(String label) =>
        tester
            .widget<CheckboxListTile>(
              find.ancestor(
                of: find.text(label),
                matching: find.byType(CheckboxListTile),
              ),
            )
            .value ??
        false;
    expect(checked('Morning'), isTrue);
    expect(checked('Evening'), isTrue);
    expect(checked('Noon'), isFalse);
    await closeApp(tester);
  });

  testWidgets('composite child toggle creates and clears entries', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.text('Marketing'));
    await tester.pumpAndSettle();

    final marketing = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('dev_marketing'))).getSingle();
    var rows = await (db.select(
      db.entries,
    )..where((e) => e.metricId.equals(marketing.id))).get();
    expect(rows, hasLength(1));

    // Chip + text field hint both say 'Marketing'; tap the chip.
    await tester.tap(find.widgetWithText(FilterChip, 'Marketing'));
    await tester.pumpAndSettle();
    rows = await (db.select(
      db.entries,
    )..where((e) => e.metricId.equals(marketing.id))).get();
    expect(rows, isEmpty);
    await closeApp(tester);
  });

  testWidgets('ADD creates a working checkbox metric', (tester) async {
    await pumpHome(tester);

    await tester.ensureVisible(find.text('ADD'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Reading');
    await tester.tap(find.text('Checkbox'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Option 1'),
      'Before bed',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final reading = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('reading'))).getSingle();
    expect(reading.inputType, 'checkbox');
    expect(reading.isStarred, isFalse);

    // New card lands at the end of the list and its checkbox works.
    await tester.ensureVisible(find.text('Before bed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Before bed'));
    await tester.pumpAndSettle();

    final optionRows = await db.select(db.entryOptions).get();
    expect(optionRows, hasLength(1));
    await closeApp(tester);
  });

  testWidgets('Del removes metric and history after confirmation', (
    tester,
  ) async {
    await pumpHome(tester);

    final delButton = find.descendant(
      of: cardOf('Extra'),
      matching: find.text('Del'),
    );
    await tester.ensureVisible(delButton);
    await tester.pumpAndSettle();
    await tester.tap(delButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('cannot be undone'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    final gone = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('extra'))).getSingleOrNull();
    expect(gone, isNull);
    await closeApp(tester);
  });
}

import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/sport_repository.dart';
import 'package:daily_tracker/features/sport/new_program_page.dart';
import 'package:daily_tracker/features/sport/sport_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR3-P5 acceptance (UI): SAVE blocked until valid; new exercise title
/// returns in the dropdown; calorie type persists and reappears.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget app(Widget home) {
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: home),
    );
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(home));
    await tester.pumpAndSettle();
  }

  testWidgets('New program: SAVE disabled until name + a valid block', (
    tester,
  ) async {
    await pump(tester, const NewProgramPage());

    final save = find.widgetWithText(FilledButton, 'Save program');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextField, 'Program name'),
      'Leg day',
    );
    await tester.pump();
    // Name alone is not enough — block has no name/sets/duration yet.
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.enterText(find.byKey(const ValueKey('block-sets-0')), '15x3');
    await tester.pump();
    // Sets without a name is still invalid.
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextField, 'Exercise name'),
      'Squat',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);

    await tester.tap(save);
    await tester.pumpAndSettle();

    final programs = await db.select(db.programs).get();
    expect(programs.single.name, 'Leg day');
    await closeApp(tester);
  });

  testWidgets('calorie entry: name + cal + ×N + category saves a food', (
    tester,
  ) async {
    await pump(tester, const SportPage());

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('calorie-name')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const ValueKey('calorie-name')),
      'Apple',
    );
    await tester.enterText(find.byKey(const ValueKey('calorie-cal')), '20');
    await tester.enterText(find.byKey(const ValueKey('calorie-qty')), '3');
    await tester.pump();

    // Tag the food's category.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Fruit'));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('calorie-save')));
    await tester.pumpAndSettle();

    final entry = (await db.select(db.calorieEntries).get()).single;
    expect(entry.type, 'Apple');
    expect(entry.quantity, 3);
    expect(entry.kcal, 60); // 20 × 3

    final apple = await (db.select(
      db.savedFoodTypes,
    )..where((t) => t.name.equals('Apple'))).getSingle();
    expect(apple.category, 'Fruit');
    expect(apple.kcalPerUnit, 20);
    await closeApp(tester);
  });

  testWidgets('tapping a saved food fills its name + per-unit calories', (
    tester,
  ) async {
    await SportRepository(
      db,
    ).upsertFood(name: 'Banana', category: 'Fruit', kcalPerUnit: 90);

    await pump(tester, const SportPage());
    await tester.scrollUntilVisible(
      find.widgetWithText(ChoiceChip, 'Fruit'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Fruit'));
    await tester.pumpAndSettle();

    // The saved food shows as a chip; tapping fills the top row.
    await tester.tap(find.widgetWithText(ActionChip, 'Banana · 90'));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byKey(const ValueKey('calorie-name'))).controller!.text,
      'Banana',
    );
    expect(
      tester.widget<TextField>(find.byKey(const ValueKey('calorie-cal'))).controller!.text,
      '90',
    );
    await closeApp(tester);
  });
}

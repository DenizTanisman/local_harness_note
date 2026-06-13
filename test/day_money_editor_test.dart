import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:daily_tracker/features/money/day_money_editor.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The editable per-day breakdown under the money form: one collapsible
/// dropdown per direction, totalled, expanding to each entry.
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
      child: MaterialApp(home: Scaffold(body: home)),
    );
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows Income/Outcome totals and expands to entries', (
    tester,
  ) async {
    final today = dateKey(DateTime.now());
    final money = MoneyRepository(db);
    await money.addTransaction(
      date: today,
      direction: 'income',
      amount: 5000,
      category: 'Salary',
    );
    await money.addTransaction(
      date: today,
      direction: 'outcome',
      amount: 100,
      category: 'Food',
    );

    await tester.pumpWidget(app(DayMoneyEditor(date: today)));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Income: 5.000 ₺'), findsOneWidget);
    expect(find.text('Outcome: 100 ₺'), findsOneWidget);

    await tester.tap(find.text('Outcome: 100 ₺'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Food'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('renders nothing when the day has no entries', (tester) async {
    await tester.pumpWidget(app(const DayMoneyEditor(date: '2020-01-01')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(ExpansionTile), findsNothing);
    await closeApp(tester);
  });
}

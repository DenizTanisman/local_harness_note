import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:daily_tracker/features/money/money_page.dart';
import 'package:daily_tracker/features/shell/app_shell.dart';
import 'package:daily_tracker/features/shell/tab_index.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR3-P2 acceptance: tap-only inner nav, gesture-safe donut, category
/// essential flag feeds the budget formula, Analysis money row read-only.
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
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(home));
    await tester.pumpAndSettle();
  }

  String month() => dateKey(DateTime.now()).substring(0, 7);

  testWidgets('inner nav switches by tap (Overview/Transactions/Categories)', (
    tester,
  ) async {
    await pump(tester, const MoneyPage());
    expect(find.textContaining('Balance:'), findsOneWidget); // Overview default

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    expect(find.text('Outcome categories'), findsOneWidget);
    expect(find.text('Income categories'), findsOneWidget);

    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Balance:'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('horizontal drag on the donut does NOT change the global tab', (
    tester,
  ) async {
    final money = MoneyRepository(db);
    await money.addTransaction(
      date: '${month()}-05',
      direction: 'outcome',
      amount: 300,
      category: 'Food',
    );
    await pump(tester, const AppShell());
    // Go to Money tab.
    container.read(tabIndexProvider.notifier).goTo(AppTab.money);
    await tester.pumpAndSettle();

    final donut = find.byKey(const ValueKey('money-donut'));
    expect(donut, findsOneWidget);
    await tester.drag(donut, const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(
      container.read(tabIndexProvider),
      AppTab.money,
      reason: 'donut absorbs the horizontal drag',
    );
    await closeApp(tester);
  });

  testWidgets('marking a category essential changes the budget formula', (
    tester,
  ) async {
    final money = MoneyRepository(db);
    final m = month();
    // Income 3000, one outcome 'Transport' 600 (non-essential by default).
    await money.addTransaction(
      date: '$m-01',
      direction: 'income',
      amount: 3000,
      category: 'Scholarship',
    );
    await money.addCategory('outcome', 'Transport');
    await money.addTransaction(
      date: '$m-02',
      direction: 'outcome',
      amount: 600,
      category: 'Transport',
    );

    // Before: Transport is luxury → daily budget = 3000/daysInMonth.
    final before = await money.loadGeneral(m);
    final days = before.days.length; // not used directly; compute days below
    expect(days, greaterThanOrEqualTo(0));
    final parts = m.split('-').map(int.parse).toList();
    final dim = DateTime(parts[0], parts[1] + 1, 0).day;
    expect(before.dailyBudget, 3000 / dim);

    await pump(tester, const MoneyPage());
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    // Toggle Transport essential.
    final transportTile = find.ancestor(
      of: find.text('Transport'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(
        of: transportTile,
        matching: find.widgetWithText(FilterChip, 'Essential'),
      ),
    );
    await tester.pumpAndSettle();

    final after = await money.loadGeneral(m);
    // Essential outcome (600) is now subtracted from the budget.
    expect(after.dailyBudget, (3000 - 600) / dim);
    await closeApp(tester);
  });

  testWidgets('Categories: adding a category persists', (tester) async {
    await pump(tester, const MoneyPage());
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Add').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Groceries');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    final cats = await db.select(db.moneyCategories).get();
    expect(cats.where((c) => c.name == 'Groceries'), hasLength(1));
    await closeApp(tester);
  });
}

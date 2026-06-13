import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:daily_tracker/features/home/home_page.dart';
import 'package:daily_tracker/features/home/home_providers.dart';
import 'package:daily_tracker/features/money/money_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 5 acceptance (UI level): money card save flow with reminder ask,
/// General blocks with subtype breakdown, Monthly table.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget app(Widget home) {
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        debounceDurationProvider.overrideWithValue(Duration.zero),
      ],
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

  testWidgets('outcome flow: amount → category → reminder ask → saved', (
    tester,
  ) async {
    await pump(tester, const HomePage());

    await tester.tap(find.text('Outcome'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('money-amount')), '2500');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('money-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bill').last);
    await tester.pumpAndSettle();

    // Reminder question appears for outcome. 'Same day' queues; offsets
    // that land before today are dropped (CR1-D).
    expect(find.text('Set a reminder?'), findsOneWidget);
    await tester.tap(find.text('Same day'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('money-subtype')), 'home');
    await tester.tap(find.byKey(const ValueKey('money-save')));
    await tester.pumpAndSettle();

    final tx = await db.select(db.transactions).get();
    expect(tx, hasLength(1));
    expect(tx.single.amount, 2500);
    expect(tx.single.category, 'Bill');
    expect(tx.single.subtype, 'home');
    expect(tx.single.date, dateKey(DateTime.now()));

    final reminders = await db.select(db.expenseReminders).get();
    expect(reminders, hasLength(1));
    await closeApp(tester);
  });

  testWidgets('income flow has no reminder question', (tester) async {
    await pump(tester, const HomePage());

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(find.text('Set a reminder?'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('Overview shows category totals with subtype breakdown', (
    tester,
  ) async {
    final money = MoneyRepository(db);
    final month = dateKey(DateTime.now()).substring(0, 7);
    await money.addTransaction(
      date: '$month-01',
      direction: 'income',
      amount: 15000,
      category: 'Scholarship',
    );
    await money.addTransaction(
      date: '$month-02',
      direction: 'outcome',
      amount: 2000,
      category: 'Bill',
      subtype: 'home',
    );
    await money.addTransaction(
      date: '$month-03',
      direction: 'outcome',
      amount: 500,
      category: 'Bill',
      subtype: 'phone',
    );

    await pump(tester, const MoneyPage());

    expect(find.text('Income: 15.000'), findsOneWidget);
    expect(find.text('Outcome: 2.500'), findsOneWidget);
    expect(find.text('> Scholarship: 15.000'), findsOneWidget);
    expect(find.text('> Bill: 2.500'), findsOneWidget);
    expect(find.text('>> Bill (home): 2.000'), findsOneWidget);
    expect(find.text('>> Bill (phone): 500'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('Transactions sub-tab lists the month entries', (tester) async {
    final money = MoneyRepository(db);
    final month = dateKey(DateTime.now()).substring(0, 7);
    await money.addTransaction(
      date: '$month-05',
      direction: 'outcome',
      amount: 100,
      category: 'Food',
    );

    await pump(tester, const MoneyPage());
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('−100 ₺'), findsOneWidget);
    await closeApp(tester);
  });
}

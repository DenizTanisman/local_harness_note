import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:daily_tracker/features/home/home_page.dart';
import 'package:daily_tracker/features/home/home_providers.dart';
import 'package:daily_tracker/features/shell/app_shell.dart';
import 'package:daily_tracker/features/shell/tab_index.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR3-P1 acceptance: dashboard summary cards deep-link to tabs; the
/// Main quick-money form writes the same data as the Money tab; Daily
/// Check-in keeps its behaviors; sensor summaries show '—'.
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
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(home));
    await tester.pumpAndSettle();
  }

  testWidgets('sensor summaries show — when there is no data', (tester) async {
    await pump(tester, const HomePage());
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Resting HR'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
    expect(find.text('—'), findsWidgets); // placeholders, no crash
    await closeApp(tester);
  });

  testWidgets('summary card taps deep-link to the right tab', (tester) async {
    await pump(tester, const AppShell());

    await tester.tap(find.text('Calories'));
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.sport);

    ref(container).goTo(AppTab.main);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Steps'));
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.health);

    ref(container).goTo(AppTab.main);
    await tester.pumpAndSettle();
    await tester.tap(find.text('This month'));
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), AppTab.money);
    await closeApp(tester);
  });

  testWidgets('Main quick-money writes to transactions at the active date', (
    tester,
  ) async {
    await pump(tester, const HomePage());

    // The only money form on Main is the dashboard quick-money card.
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('money-amount')), '500');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('money-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scholarship').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('money-save')));
    await tester.pumpAndSettle();

    final tx = await db.select(db.transactions).get();
    expect(tx, hasLength(1));
    expect(tx.single.direction, 'income');
    expect(tx.single.amount, 500);
    expect(tx.single.date, dateKey(DateTime.now()));
    await closeApp(tester);
  });

  testWidgets('balance card reflects the month net from transactions', (
    tester,
  ) async {
    final money = MoneyRepository(db);
    final month = dateKey(DateTime.now()).substring(0, 7);
    await money.addTransaction(
      date: '$month-01',
      direction: 'income',
      amount: 20000,
      category: 'Scholarship',
    );
    await money.addTransaction(
      date: '$month-02',
      direction: 'outcome',
      amount: 7600,
      category: 'Rent',
    );

    await pump(tester, const HomePage());
    expect(find.text('+12.400 ₺'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('money metric in check-in is a read-only deep link', (
    tester,
  ) async {
    await pump(tester, const AppShell());
    // The check-in money row deep-links; no second Income/Outcome form.
    expect(find.text('Income'), findsOneWidget); // only the quick-money one
    expect(find.text('Open Money'), findsOneWidget);
    await closeApp(tester);
  });
}

TabIndexNotifier ref(ProviderContainer c) => c.read(tabIndexProvider.notifier);

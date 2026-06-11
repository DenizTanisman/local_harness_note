import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:daily_tracker/features/home/home_page.dart';
import 'package:daily_tracker/features/home/home_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR1-D acceptance: past-day entry from the home page; future blocked;
/// chip + Today button; no reminders for past days.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  String daysAgo(int n) => dateKey(DateTime.now().subtract(Duration(days: n)));

  Widget app() {
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        debounceDurationProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HomePage()),
    );
  }

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

  group('ActiveWriteDateNotifier', () {
    test('future rejected, past accepted, reset returns to today', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(homeDateProvider.notifier);

      expect(container.read(homeDateProvider), dateKey(DateTime.now()));
      notifier.select(daysAgo(-2)); // future
      expect(container.read(homeDateProvider), dateKey(DateTime.now()));
      notifier.select(daysAgo(1));
      expect(container.read(homeDateProvider), daysAgo(1));
      notifier.resetToToday();
      expect(container.read(homeDateProvider), dateKey(DateTime.now()));
    });
  });

  group('reminders on past days (CR1-D)', () {
    test('past-day outcome writes NO expense_reminders rows', () async {
      final money = MoneyRepository(db);
      await money.addTransaction(
        date: daysAgo(3),
        direction: 'outcome',
        amount: 100,
        category: 'Bill',
        reminderOffsets: [0, 1, 2, 3],
      );
      expect(await db.select(db.expenseReminders).get(), isEmpty);
    });

    test('today outcome with same-day offset still queues', () async {
      final money = MoneyRepository(db);
      await money.addTransaction(
        date: dateKey(DateTime.now()),
        direction: 'outcome',
        amount: 100,
        category: 'Bill',
        reminderOffsets: [0, 1], // '1 day before' lands in the past → dropped
      );
      final rows = await db.select(db.expenseReminders).get();
      expect(rows, hasLength(1));
      expect(rows.single.remindDate, dateKey(DateTime.now()));
    });
  });

  group('home page past mode', () {
    testWidgets(
      'enter Water yesterday → back to today: today empty, yesterday kept',
      (tester) async {
        await pumpHome(tester);

        // Today: chip not highlighted, no Today button.
        expect(find.byKey(const ValueKey('today-button')), findsNothing);

        container.read(homeDateProvider.notifier).select(daysAgo(1));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('today-button')), findsOneWidget);
        expect(find.text(daysAgo(1)), findsOneWidget);

        final waterField = find.descendant(
          of: find
              .ancestor(of: find.text('Water'), matching: find.byType(Card))
              .first,
          matching: find.byType(TextField),
        );
        await tester.enterText(waterField, '2');
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('today-button')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('today-button')), findsNothing);

        final reopened = tester.widget<TextField>(
          find.descendant(
            of: find
                .ancestor(of: find.text('Water'), matching: find.byType(Card))
                .first,
            matching: find.byType(TextField),
          ),
        );
        expect(
          reopened.controller!.text,
          isEmpty,
          reason: 'today must be untouched',
        );

        final water = await (db.select(
          db.metrics,
        )..where((m) => m.key.equals('water'))).getSingle();
        final rows = await (db.select(
          db.entries,
        )..where((e) => e.metricId.equals(water.id))).get();
        expect(rows, hasLength(1));
        expect(rows.single.date, daysAgo(1));
        expect(rows.single.numValue, 2);
        await closeApp(tester);
      },
    );

    testWidgets('reminder question hidden on a past day', (tester) async {
      await pumpHome(tester);
      container.read(homeDateProvider.notifier).select(daysAgo(2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Outcome'));
      await tester.pumpAndSettle();
      expect(find.text('Set a reminder?'), findsNothing);

      container.read(homeDateProvider.notifier).resetToToday();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Outcome'));
      await tester.pumpAndSettle();
      expect(find.text('Set a reminder?'), findsOneWidget);
      await closeApp(tester);
    });
  });
}

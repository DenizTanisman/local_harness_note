import 'package:local_harness_not/core/date_key.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/db/database_provider.dart';
import 'package:local_harness_not/features/home/home_page.dart';
import 'package:local_harness_not/features/home/home_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Successor of the monolith's main_dashboard_test: in the Not app Main is
/// the Daily Check-in only. The dashboard cards (quick money, Today summary,
/// balance) and their tab deep links moved to the Hub app.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget app() {
    final container = ProviderContainer(
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

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Main is the check-in: no dashboard summary cards', (
    tester,
  ) async {
    await pump(tester);
    expect(find.widgetWithText(AppBar, 'Not'), findsOneWidget);
    expect(find.text('Daily Check-in'), findsOneWidget);
    for (final gone in [
      'Quick money',
      'Today',
      'Calories',
      'Steps',
      'Resting HR',
      'Screen time',
      'This month',
      'Spent today',
      'Income',
      'Outcome',
    ]) {
      expect(find.text(gone), findsNothing, reason: gone);
    }
    await closeApp(tester);
  });

  testWidgets('every top-level card is a check-in metric (no money form)', (
    tester,
  ) async {
    await pump(tester);
    // 8 top-level cards; Development's children render inside its card.
    expect(find.byType(Card), findsNWidgets(8));
    expect(find.text('Money'), findsNothing);
    expect(find.byKey(const ValueKey('money-amount')), findsNothing);
    await closeApp(tester);
  });

  testWidgets('filling a card writes today and the ADD button stays', (
    tester,
  ) async {
    await pump(tester);
    final waterField = find.descendant(
      of: find
          .ancestor(of: find.text('Water'), matching: find.byType(Card))
          .first,
      matching: find.byType(TextField),
    );
    await tester.enterText(waterField, '3');
    await tester.pumpAndSettle();

    final rows = await db.select(db.entries).get();
    expect(rows, hasLength(1));
    expect(rows.single.date, dateKey(DateTime.now()));
    expect(rows.single.numValue, 3);
    expect(find.text('ADD'), findsOneWidget);
    await closeApp(tester);
  });
}

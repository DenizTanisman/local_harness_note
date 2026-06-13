import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:daily_tracker/features/analysis/analysis_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/money_test_support.dart';

/// CR1-A acceptance: all levels collapsed on first open; Money expands
/// 3 levels deep; arrow toggles vs title navigation are separate targets.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  String daysAgo(int n) => dateKey(DateTime.now().subtract(Duration(days: n)));

  Widget app({void Function(Metric)? onMetricTap}) {
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db), revealAllOverride],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: AnalysisPage(onMetricTap: onMetricTap)),
    );
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> seedThreeLevels() async {
    final money = MoneyRepository(db);
    final date = daysAgo(1);
    await money.addTransaction(
      date: date,
      direction: 'outcome',
      amount: 150,
      category: 'Food',
      subtype: 'campus',
    );
    await money.addTransaction(
      date: date,
      direction: 'outcome',
      amount: 50,
      category: 'Food',
    );
    final leadership = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('dev_leadership'))).getSingle();
    await EntryRepository(db).saveEntry(
      metricId: leadership.id,
      date: date,
      textValue: 'Being more precise and consistent',
    );
  }

  testWidgets('first open: roots + level-1 headers only, nothing expanded', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seedThreeLevels();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Roots and level-1 headers are visible…
    expect(find.text('Money: 200 TL'), findsOneWidget);
    expect(find.text('Outcome (Month): 200'), findsOneWidget);
    expect(find.text('Development: Leadership'), findsOneWidget);
    expect(find.text('Leadership'), findsOneWidget);
    // …but no deeper level is.
    expect(find.text('Food: 200'), findsNothing);
    expect(find.text('Food (campus): 150'), findsNothing);
    expect(find.text('Being more precise and consistent'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('money expands 3 levels: direction → category → subtype', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seedThreeLevels();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('toggle-money/outcome')));
    await tester.pumpAndSettle();
    expect(find.text('Food: 200'), findsOneWidget);
    expect(find.text('Food (campus): 150'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('toggle-money/outcome/Food')));
    await tester.pumpAndSettle();
    expect(find.text('Food (campus): 150'), findsOneWidget);

    // Collapse the middle level → subtype disappears with it.
    await tester.tap(find.byKey(const ValueKey('toggle-money/outcome')));
    await tester.pumpAndSettle();
    expect(find.text('Food: 200'), findsNothing);
    expect(find.text('Food (campus): 150'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('development note appears only after expanding the child', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seedThreeLevels();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Being more precise and consistent'), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('toggle-development/dev_leadership')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Being more precise and consistent'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('arrow toggles while title navigates — separate targets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seedThreeLevels();
    Metric? tapped;
    await tester.pumpWidget(app(onMetricTap: (m) => tapped = m));
    await tester.pumpAndSettle();

    // Title tap → navigation, no expansion.
    await tester.tap(find.byKey(const ValueKey('title-money/outcome')));
    await tester.pumpAndSettle();
    expect(tapped?.key, 'money');
    expect(find.text('Food: 200'), findsNothing);

    // Arrow tap → expansion, no navigation.
    tapped = null;
    await tester.tap(find.byKey(const ValueKey('toggle-money/outcome')));
    await tester.pumpAndSettle();
    expect(tapped, isNull);
    expect(find.text('Food: 200'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('empty Income block shows no arrow', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seedThreeLevels(); // outcome only — income is empty
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Income (Month): 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('toggle-money/income')), findsNothing);
    expect(find.byKey(const ValueKey('toggle-money/outcome')), findsOneWidget);
    await closeApp(tester);
  });
}

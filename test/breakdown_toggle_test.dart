import 'package:local_harness_not/core/date_key.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/db/database_provider.dart';
import 'package:local_harness_not/data/repositories/entry_repository.dart';
import 'package:local_harness_not/features/analysis/analysis_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CR1-A acceptance (Not app — the Money 3-level tree moved to Para): all
/// levels collapsed on first open; composite → child → note expands level
/// by level; arrow toggles vs title navigation are separate targets.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  String daysAgo(int n) => dateKey(DateTime.now().subtract(Duration(days: n)));

  Widget app({void Function(Metric)? onMetricTap}) {
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
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

  Future<Metric> byKey(String key) =>
      (db.select(db.metrics)..where((m) => m.key.equals(key))).getSingle();

  Future<void> seedThreeLevels() async {
    final entries = EntryRepository(db);
    // Shared selected day now defaults to today, so seed the day under view.
    final date = daysAgo(0);
    await entries.saveEntry(
      metricId: (await byKey('dev_leadership')).id,
      date: date,
      textValue: 'Being more precise and consistent',
    );
    // A filled child WITHOUT a note → no arrow on its row.
    await entries.saveEntry(
      metricId: (await byKey('dev_social')).id,
      date: date,
      textValue: '',
    );
    await entries.saveEntry(
      metricId: (await byKey('software')).id,
      date: date,
      numValue: 45,
      textValue: 'Refactored the parser',
    );
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    void Function(Metric)? onMetricTap,
  }) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seedThreeLevels();
    await tester.pumpWidget(app(onMetricTap: onMetricTap));
    await tester.pumpAndSettle();
  }

  testWidgets('first open: roots + level-1 rows only, nothing expanded', (
    tester,
  ) async {
    await pumpPage(tester);

    // Roots and level-1 rows are visible…
    expect(find.text('Development: Leadership, Social'), findsOneWidget);
    expect(find.text('Leadership'), findsOneWidget);
    expect(find.text('Social'), findsOneWidget);
    expect(find.text('Software: 45 min'), findsOneWidget);
    // …but no deeper level is.
    expect(find.text('Being more precise and consistent'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('development note appears only after expanding the child', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Being more precise and consistent'), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('toggle-development/dev_leadership')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Being more precise and consistent'), findsOneWidget);

    // Collapse again → the note disappears with it.
    await tester.tap(
      find.byKey(const ValueKey('toggle-development/dev_leadership')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Being more precise and consistent'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('arrow toggles while title navigates — separate targets', (
    tester,
  ) async {
    Metric? tapped;
    await pumpPage(tester, onMetricTap: (m) => tapped = m);

    // Title tap → navigation, no expansion.
    await tester.tap(
      find.byKey(const ValueKey('title-development/dev_leadership')),
    );
    await tester.pumpAndSettle();
    expect(tapped?.key, 'dev_leadership');
    expect(find.text('Being more precise and consistent'), findsNothing);

    // Arrow tap → expansion, no navigation.
    tapped = null;
    await tester.tap(
      find.byKey(const ValueKey('toggle-development/dev_leadership')),
    );
    await tester.pumpAndSettle();
    expect(tapped, isNull);
    expect(find.text('Being more precise and consistent'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('long note leaf un-ellipsizes in place via its arrow', (
    tester,
  ) async {
    await pumpPage(tester);
    final note = find.byKey(const ValueKey('title-software/note'));
    expect(
      tester
          .widget<Text>(find.descendant(of: note, matching: find.byType(Text)))
          .maxLines,
      1,
    );
    await tester.tap(find.byKey(const ValueKey('toggle-software/note')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.descendant(of: note, matching: find.byType(Text)))
          .maxLines,
      isNull,
    );
    await closeApp(tester);
  });

  testWidgets('a child without a note shows no arrow', (tester) async {
    await pumpPage(tester);

    expect(
      find.byKey(const ValueKey('toggle-development/dev_social')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('toggle-development/dev_leadership')),
      findsOneWidget,
    );
    await closeApp(tester);
  });
}

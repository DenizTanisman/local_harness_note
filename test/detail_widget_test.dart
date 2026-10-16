import 'package:local_harness_not/core/date_key.dart';
import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/db/database_provider.dart';
import 'package:local_harness_not/data/repositories/entry_repository.dart';
import 'package:local_harness_not/features/analysis/analysis_providers.dart';
import 'package:local_harness_not/features/detail/metric_detail_page.dart';
import 'package:local_harness_not/features/shell/app_shell.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 4 acceptance (UI level): every analysis header opens its detail
/// page; sparkline dot tap jumps the date.
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

  String daysAgo(int n) => dateKey(DateTime.now().subtract(Duration(days: n)));

  testWidgets('heatmap label tap opens the metric detail page', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(const AppShell()));
    await tester.pumpAndSettle();
    // Reach Analysis (index 1) via the bottom nav.
    await tester.tap(find.text('Analysis').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final softwareLabel = find.descendant(
      of: find.byKey(const ValueKey('heatmap-grid')).hitTestable(),
      matching: find.text('Software'),
    );
    // Labels live next to the grid; find via the label key instead.
    final label = softwareLabel.evaluate().isEmpty
        ? find.text('Software').first
        : softwareLabel;
    await tester.tap(label);
    await tester.pumpAndSettle();

    expect(find.byType(MetricDetailPage), findsOneWidget);
    expect(find.byKey(const ValueKey('sparkline')), findsOneWidget);
    expect(find.textContaining('Daily:'), findsOneWidget);
    expect(find.textContaining('Weekly:'), findsOneWidget);
    expect(find.textContaining('Monthly:'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('breakdown header tap opens detail; back returns to analysis', (
    tester,
  ) async {
    final software = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('software'))).getSingle();
    await EntryRepository(
      db,
    ).saveEntry(metricId: software.id, date: daysAgo(0), numValue: 42);

    await tester.pumpWidget(app(const AppShell()));
    await tester.pumpAndSettle();
    // Reach Analysis (index 1) via the bottom nav.
    await tester.tap(find.text('Analysis').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byKey(const ValueKey('breakdown-software')));
    await tester.pumpAndSettle();
    expect(find.byType(MetricDetailPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Analysis'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('sparkline dot tap selects that day', (tester) async {
    final software = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('software'))).getSingle();
    // Use LAST month: every one of its days is in the past, so selecting
    // day 5 can never be rejected as a future date (the old version used
    // the current month and failed during the first days of a month).
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 15);
    final month = dateKey(lastMonth).substring(0, 7);
    // Data on day 5 of the selected month.
    await EntryRepository(
      db,
    ).saveEntry(metricId: software.id, date: '$month-05', numValue: 30);

    await tester.pumpWidget(app(MetricDetailPage(metric: software)));
    container.read(selectedDateProvider.notifier).select(dateKey(lastMonth));
    await tester.pumpAndSettle();

    final spark = find.byKey(const ValueKey('sparkline'));
    final rect = tester.getRect(spark);
    final days = DateTime(lastMonth.year, lastMonth.month + 1, 0).day;
    final step = rect.width / (days - 1);
    await tester.tapAt(Offset(rect.left + step * 4, rect.center.dy));
    await tester.pumpAndSettle();

    expect(container.read(selectedDateProvider), '$month-05');
    await closeApp(tester);
  });
}

import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/features/analysis/analysis_providers.dart';
import 'package:daily_tracker/features/detail/metric_detail_page.dart';
import 'package:daily_tracker/features/shell/root_pager.dart';
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

  testWidgets('heatmap label tap opens the metric detail page',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(const RootPager()));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1200);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final softwareLabel = find.descendant(
        of: find.byKey(const ValueKey('heatmap-grid')).hitTestable(),
        matching: find.text('Software'));
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

  testWidgets('breakdown header tap opens detail; back returns to analysis',
      (tester) async {
    final software = await (db.select(db.metrics)
          ..where((m) => m.key.equals('software')))
        .getSingle();
    await EntryRepository(db)
        .saveEntry(metricId: software.id, date: daysAgo(1), numValue: 42);

    await tester.pumpWidget(app(const RootPager()));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1200);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byKey(const ValueKey('breakdown-software')));
    await tester.pumpAndSettle();
    expect(find.byType(MetricDetailPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Analysis'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('sparkline dot tap selects that day', (tester) async {
    final software = await (db.select(db.metrics)
          ..where((m) => m.key.equals('software')))
        .getSingle();
    final selected = daysAgo(1);
    final month = selected.substring(0, 7);
    // Data on day 5 of the selected month.
    await EntryRepository(db)
        .saveEntry(metricId: software.id, date: '$month-05', numValue: 30);

    await tester.pumpWidget(app(MetricDetailPage(metric: software)));
    await tester.pumpAndSettle();

    final spark = find.byKey(const ValueKey('sparkline'));
    final rect = tester.getRect(spark);
    final days = DateTime(
      int.parse(month.substring(0, 4)),
      int.parse(month.substring(5, 7)) + 1,
      0,
    ).day;
    final step = rect.width / (days - 1);
    await tester.tapAt(Offset(rect.left + step * 4, rect.center.dy));
    await tester.pumpAndSettle();

    expect(container.read(selectedDateProvider), '$month-05');
    await closeApp(tester);
  });
}

import 'package:daily_tracker/core/date_key.dart';
import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/db/database_provider.dart';
import 'package:daily_tracker/data/repositories/analysis_repository.dart';
import 'package:daily_tracker/data/repositories/detail_repository.dart';
import 'package:daily_tracker/features/analysis/analysis_page.dart';
import 'package:daily_tracker/features/analysis/heatmap_widget.dart';
import 'package:daily_tracker/features/home/home_page.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 8 acceptance: a full year of data stays fast and every page
/// still renders; empty states exist.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// 365 days of entries for all leaf metrics + daily transactions.
  Future<void> seedYear() async {
    final metrics = await db.select(db.metrics).get();
    final now = DateTime.now().millisecondsSinceEpoch;
    final start = DateTime.now().subtract(const Duration(days: 365));
    await db.batch((batch) {
      for (var i = 0; i < 365; i++) {
        final date = dateKey(start.add(Duration(days: i)));
        for (final metric in metrics) {
          if (metric.inputType == 'money' ||
              metric.inputType == 'composite') {
            continue;
          }
          batch.insert(
            db.entries,
            EntriesCompanion.insert(
              metricId: metric.id,
              date: date,
              numValue: Value((i % 90).toDouble()),
              textValue: Value(i % 3 == 0 ? 'note $i' : null),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
        batch.insert(
          db.transactions,
          TransactionsCompanion.insert(
            date: date,
            direction: i % 5 == 0 ? 'income' : 'outcome',
            amount: 100 + (i % 700).toDouble(),
            category: i % 5 == 0
                ? 'Scholarship'
                : ['Rent', 'Bill', 'Food', 'Entertainment'][i % 4],
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    });
  }

  test('one year of data: heatmap window loads fast', () async {
    await seedYear();
    final analysis = AnalysisRepository(db);

    // Warm-up (first query pays sqlite page-cache costs).
    await analysis.loadHeatmap(dateKey(DateTime.now()), 60);

    final watch = Stopwatch()..start();
    final matrix = await analysis.loadHeatmap(dateKey(DateTime.now()), 60);
    watch.stop();

    expect(matrix.dates, hasLength(60));
    expect(matrix.values.values.every((v) => v.isNotEmpty), isTrue);
    // Repository load well under a frame budget's order of magnitude.
    expect(watch.elapsedMilliseconds, lessThan(250),
        reason: 'heatmap load took ${watch.elapsedMilliseconds}ms');
  });

  test('one year of data: breakdown and month series stay fast', () async {
    await seedYear();
    final analysis = AnalysisRepository(db);
    final detail = DetailRepository(db);
    final software = await (db.select(db.metrics)
          ..where((m) => m.key.equals('software')))
        .getSingle();

    final watch = Stopwatch()..start();
    await analysis.loadBreakdown(dateKey(DateTime.now()));
    await detail.loadMonthSeries(
        software, dateKey(DateTime.now()).substring(0, 7));
    await detail.loadStats(software, dateKey(DateTime.now()));
    watch.stop();
    expect(watch.elapsedMilliseconds, lessThan(500),
        reason: 'detail pipeline took ${watch.elapsedMilliseconds}ms');
  });

  testWidgets('analysis page renders smoothly with a year of data',
      (tester) async {
    await seedYear();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AnalysisPage()),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(HeatmapWidget), findsOneWidget);
    expect(find.byKey(const ValueKey('heatmap-grid')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('home shows an empty state when every metric is deleted',
      (tester) async {
    await db.delete(db.metrics).go();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HomePage()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('No metrics yet.'), findsOneWidget);
    expect(find.text('ADD'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  });
}

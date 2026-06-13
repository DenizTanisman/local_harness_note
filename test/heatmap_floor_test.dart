import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/repositories/analysis_repository.dart';
import 'package:daily_tracker/data/repositories/entry_repository.dart';
import 'package:daily_tracker/data/repositories/money_repository.dart';
import 'package:daily_tracker/features/analysis/analysis_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Heatmap monthly window + per-metric data floor (Money since 2026-04-15,
/// everything else since 2026-06-13).
void main() {
  late AppDatabase db;
  late AnalysisRepository analysis;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    analysis = AnalysisRepository(db);
  });
  tearDown(() => db.close());

  Future<Metric> byKey(String key) =>
      (db.select(db.metrics)..where((m) => m.key.equals(key))).getSingle();

  test('heatmapDataFloor: money 2026-04-15, others 2026-06-13', () {
    expect(heatmapDataFloor('money'), '2026-04-15');
    expect(heatmapDataFloor('software'), '2026-06-13');
    expect(heatmapDataFloor('water'), '2026-06-13');
  });

  test('monthly window: a full calendar month of columns', () async {
    // June 2026 → endDate 2026-06-30, days 30.
    final m = await analysis.loadHeatmap(
      '2026-06-30',
      30,
      floorFor: heatmapDataFloor,
      todayKey: '2026-12-31',
    );
    expect(m.dates.first, '2026-06-01');
    expect(m.dates.last, '2026-06-30');
    expect(m.dates.length, 30);
  });

  test(
    'non-money: days before 2026-06-13 are empty, on/after are 0-filled',
    () async {
      final software = await byKey('software');
      final m = await analysis.loadHeatmap(
        '2026-06-30',
        30,
        floorFor: heatmapDataFloor,
        todayKey: '2026-12-31',
      );
      final vals = m.values[software.id]!;
      expect(vals.containsKey('2026-06-12'), isFalse, reason: 'before floor');
      expect(vals['2026-06-13'], 0, reason: 'on floor → 0-filled');
      expect(vals['2026-06-20'], 0);
    },
  );

  test(
    'money: floor is 2026-04-15, so April after the 15th is 0-filled',
    () async {
      final money = await byKey('money');
      final april = await analysis.loadHeatmap(
        '2026-04-30',
        30,
        floorFor: heatmapDataFloor,
        todayKey: '2026-12-31',
      );
      final vals = april.values[money.id]!;
      expect(vals.containsKey('2026-04-14'), isFalse, reason: 'before floor');
      expect(vals['2026-04-15'], 0, reason: 'on floor → darkGreen 0-sum');
      expect(vals['2026-04-20'], 0);
      // Non-money in April is entirely empty (floor is June).
      final software = await byKey('software');
      expect(april.values[software.id], isEmpty);
    },
  );

  test('future days after today are empty', () async {
    final software = await byKey('software');
    final m = await analysis.loadHeatmap(
      '2026-06-30',
      30,
      floorFor: heatmapDataFloor,
      todayKey: '2026-06-20',
    );
    final vals = m.values[software.id]!;
    expect(vals['2026-06-20'], 0, reason: 'today included');
    expect(vals.containsKey('2026-06-21'), isFalse, reason: 'future empty');
  });

  test('real entered values still show after the floor', () async {
    final software = await byKey('software');
    await EntryRepository(
      db,
    ).saveEntry(metricId: software.id, date: '2026-06-15', numValue: 35);
    await MoneyRepository(db).addTransaction(
      date: '2026-06-15',
      direction: 'outcome',
      amount: 100,
      category: 'Food',
    );

    final m = await analysis.loadHeatmap(
      '2026-06-30',
      30,
      floorFor: heatmapDataFloor,
      todayKey: '2026-12-31',
    );
    expect(m.values[software.id]!['2026-06-15'], 35);
    final money = await byKey('money');
    expect(m.values[money.id]!['2026-06-15'], 100);
  });
}

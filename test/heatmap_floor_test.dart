import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/analysis_repository.dart';
import 'package:local_harness_not/data/repositories/entry_repository.dart';
import 'package:local_harness_not/features/analysis/analysis_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Heatmap monthly window + per-metric data floor (every check-in metric
/// since 2026-06-13; the Money 2026-04-15 floor moved to Para with Money).
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

  test('heatmapDataFloor: every metric 2026-06-13', () {
    expect(heatmapDataFloor('software'), '2026-06-13');
    expect(heatmapDataFloor('instagram'), '2026-06-13');
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

  test('days before 2026-06-13 are empty, on/after are 0-filled', () async {
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
  });

  test('a month entirely before the floor is empty', () async {
    final april = await analysis.loadHeatmap(
      '2026-04-30',
      30,
      floorFor: heatmapDataFloor,
      todayKey: '2026-12-31',
    );
    final software = await byKey('software');
    expect(april.values[software.id], isEmpty);
  });

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

    final m = await analysis.loadHeatmap(
      '2026-06-30',
      30,
      floorFor: heatmapDataFloor,
      todayKey: '2026-12-31',
    );
    expect(m.values[software.id]!['2026-06-15'], 35);
  });
}

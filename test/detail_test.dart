import 'package:local_harness_not/data/db/app_database.dart';
import 'package:local_harness_not/data/repositories/detail_repository.dart';
import 'package:local_harness_not/data/repositories/entry_repository.dart';
import 'package:local_harness_not/data/heatmap/heatmap_rule.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 4 acceptance (repository level): month window boundaries
/// (31 vs 30-day months), Daily/Weekly/Monthly sums.
void main() {
  late AppDatabase db;
  late DetailRepository detail;
  late EntryRepository entries;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    detail = DetailRepository(db);
    entries = EntryRepository(db);
  });
  tearDown(() => db.close());

  Future<Metric> byKey(String key) =>
      (db.select(db.metrics)..where((m) => m.key.equals(key))).getSingle();

  test('month series window matches month length (30 vs 31 days)', () async {
    final software = await byKey('software');
    // Last day of June (30) and first of July (31) must land in
    // different windows.
    await entries.saveEntry(
      metricId: software.id,
      date: '2026-06-30',
      numValue: 30,
    );
    await entries.saveEntry(
      metricId: software.id,
      date: '2026-07-01',
      numValue: 31,
    );
    await entries.saveEntry(
      metricId: software.id,
      date: '2026-07-31',
      numValue: 99,
    );

    final june = await detail.loadMonthSeries(software, '2026-06');
    expect(june.daysInMonth, 30);
    expect(june.values[30], 30);
    expect(june.values.containsKey(1), isFalse);

    final july = await detail.loadMonthSeries(software, '2026-07');
    expect(july.daysInMonth, 31);
    expect(july.values[1], 31);
    expect(july.values[31], 99);

    final feb = await detail.loadMonthSeries(software, '2026-02');
    expect(feb.daysInMonth, 28);
  });

  test('daily/weekly/monthly sums for a numeric metric', () async {
    final software = await byKey('software');
    // 2026-06-10 is a Wednesday; its Mon–Sun week is 06-08..06-14.
    await entries.saveEntry(
      metricId: software.id,
      date: '2026-06-08',
      numValue: 10,
    );
    await entries.saveEntry(
      metricId: software.id,
      date: '2026-06-10',
      numValue: 35,
    );
    await entries.saveEntry(
      metricId: software.id,
      date: '2026-06-14',
      numValue: 5,
    );
    await entries.saveEntry(
      metricId: software.id,
      date: '2026-06-01',
      numValue: 100,
    );
    await entries.saveEntry(
      metricId: software.id,
      date: '2026-07-01',
      numValue: 999,
    );

    final stats = await detail.loadStats(software, '2026-06-10');
    expect(stats.daily, 35);
    expect(stats.weekly, 50); // 10 + 35 + 5
    expect(stats.monthly, 150); // + 100, July excluded
  });

  test(
    'weekly window crossing a month boundary still sums correctly',
    () async {
      final water = await byKey('water');
      // 2026-07-01 is a Wednesday; its week starts Mon 2026-06-29.
      await entries.saveEntry(
        metricId: water.id,
        date: '2026-06-29',
        numValue: 2,
      );
      await entries.saveEntry(
        metricId: water.id,
        date: '2026-07-01',
        numValue: 3,
      );

      final stats = await detail.loadStats(water, '2026-07-01');
      expect(stats.daily, 3);
      expect(stats.weekly, 5); // June 29 included
      expect(stats.monthly, 3); // June excluded
    },
  );

  test('checkbox metric uses option_count as its series source', () async {
    final brushing = await byKey('brushing');
    expect(detail.sourceFor(brushing), HeatmapSource.optionCount);

    final options = await (db.select(
      db.metricOptions,
    )..where((o) => o.metricId.equals(brushing.id))).get();
    for (final option in options) {
      await entries.setOptionSelected(
        metricId: brushing.id,
        optionId: option.id,
        date: '2026-06-10',
        selected: true,
      );
    }
    final stats = await detail.loadStats(brushing, '2026-06-10');
    expect(stats.daily, 3);
  });
}

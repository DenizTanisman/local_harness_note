import 'package:daily_tracker/data/db/app_database.dart';
import 'package:daily_tracker/data/heatmap/heatmap_rule.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// v9 migration: existing installs get the modern blue heatmap rules and the
/// Waste option renamed to 'Energy Waste'.
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('applyBlueHeatmapRules recolours core rules + renames Waste', () async {
    // Simulate a pre-v9 install: legacy yellow Development rule + old label.
    final dev = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('development'))).getSingle();
    await (db.update(db.metrics)..where((m) => m.id.equals(dev.id))).write(
      const MetricsCompanion(
        heatmapRule: Value(
          '{"source":"filled_subcount","buckets":['
          '{"min":0,"max":1,"color":"black"},'
          '{"min":1,"max":2,"color":"lightYellow"},'
          '{"min":2,"max":3,"color":"yellow"},'
          '{"min":3,"max":null,"color":"darkYellow"}]}',
        ),
      ),
    );
    final waste = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('waste'))).getSingle();
    await (db.update(
      db.metricOptions,
    )..where((o) => o.metricId.equals(waste.id))).write(
      const MetricOptionsCompanion(label: Value('Honest energy waste — yes')),
    );

    await db.applyBlueHeatmapRules();

    final devAfter = await (db.select(
      db.metrics,
    )..where((m) => m.id.equals(dev.id))).getSingle();
    final rule = HeatmapRule.decode(devAfter.heatmapRule!);
    expect(rule.colorFor(1), 'lightBlue');
    expect(rule.colorFor(2), 'blue');
    expect(rule.colorFor(3), 'darkBlue');

    final opt = await (db.select(
      db.metricOptions,
    )..where((o) => o.metricId.equals(waste.id))).getSingle();
    expect(opt.label, 'Energy Waste');
  });
}

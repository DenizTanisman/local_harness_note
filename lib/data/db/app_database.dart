import 'package:drift/drift.dart';

import 'seed_data.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Metrics, MetricOptions, Entries, EntryOptions, AppSettings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Fresh install of the split-out Not app: the monolith's v1→v10 upgrade
  /// chain does not apply (no device ever ran an older Not schema).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('CREATE INDEX idx_entries_date ON entries(date)');
      await customStatement(
        'CREATE INDEX idx_metrics_parent ON metrics(parent_id)',
      );
      await _seed();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Restores a promoted leaf to its original input type once it has no
  /// children left. Natural composites (prev_input_type NULL) are
  /// untouched. Called by every flow that removes a child from a parent.
  Future<void> demoteIfChildless(int metricId) async {
    final metric = await (select(
      metrics,
    )..where((m) => m.id.equals(metricId))).getSingleOrNull();
    if (metric == null || metric.prevInputType == null) return;
    final childCount = metrics.id.count();
    final row =
        await (selectOnly(metrics)
              ..addColumns([childCount])
              ..where(metrics.parentId.equals(metricId)))
            .getSingle();
    if ((row.read(childCount) ?? 0) > 0) return;
    await (update(metrics)..where((m) => m.id.equals(metricId))).write(
      MetricsCompanion(
        inputType: Value(metric.prevInputType!),
        prevInputType: const Value(null),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Repair for a leaf promoted to composite without prev_input_type
  /// memory (monolith v4 migration), kept as a self-heal helper. Core metric
  /// types are known from the seed — childless composites are restored
  /// outright; composites that still hold children keep working as groups
  /// but get their seed type written into prev_input_type so the next
  /// detach restores them.
  Future<void> repairCorruptedCoreTypes() async {
    for (final seed in seedMetrics) {
      if (seed.inputType == 'composite') continue; // development is natural
      final row = await (select(
        metrics,
      )..where((m) => m.key.equals(seed.key))).getSingleOrNull();
      if (row == null || row.inputType != 'composite') continue;
      final childCount = metrics.id.count();
      final children =
          await (selectOnly(metrics)
                ..addColumns([childCount])
                ..where(metrics.parentId.equals(row.id)))
              .getSingle();
      final hasChildren = (children.read(childCount) ?? 0) > 0;
      await (update(metrics)..where((m) => m.id.equals(row.id))).write(
        hasChildren
            ? MetricsCompanion(prevInputType: Value(seed.inputType))
            : MetricsCompanion(
                inputType: Value(seed.inputType),
                prevInputType: const Value(null),
              ),
      );
    }
  }

  /// Rewrites the seeded heatmap rules to their current (blue) definitions
  /// and renames the legacy Waste option (monolith v9 body, kept as a
  /// reset helper; exposed for tests).
  Future<void> applyBlueHeatmapRules() async {
    for (final seed in seedMetrics) {
      if (seed.heatmapRule == null) continue;
      await (update(metrics)..where((m) => m.key.equals(seed.key))).write(
        MetricsCompanion(heatmapRule: Value(seed.heatmapRule)),
      );
    }
    await customStatement(
      "UPDATE metric_options SET label = 'Energy Waste' "
      "WHERE label = 'Honest energy waste — yes'",
    );
  }

  /// Protects the core seed metrics by KEY (CR-2), exposed for tests.
  Future<void> markCoreUndeletable() {
    return (update(metrics)..where((m) => m.key.isIn(coreMetricKeys))).write(
      const MetricsCompanion(isDeletable: Value(false)),
    );
  }

  /// Debounced auto-save target (spec 6.2): one row per metric × day.
  /// On conflict the value columns are updated; created_at is preserved.
  Future<int> upsertEntry(EntriesCompanion entry) {
    return into(entries).insert(
      entry,
      onConflict: DoUpdate(
        (old) => EntriesCompanion(
          numValue: entry.numValue,
          textValue: entry.textValue,
          valueSource: entry.valueSource,
          updatedAt: entry.updatedAt,
        ),
        target: [entries.metricId, entries.date],
      ),
    );
  }

  Future<void> _seed() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await transaction(() async {
      final idsByKey = <String, int>{};
      var order = 0;
      for (final seed in seedMetrics) {
        final id = await into(metrics).insert(
          MetricsCompanion.insert(
            parentId: Value(
              seed.parentKey == null ? null : idsByKey[seed.parentKey]!,
            ),
            key: seed.key,
            title: seed.title,
            inputType: seed.inputType,
            isStarred: Value(seed.starred),
            isDeletable: const Value(false), // core seed protected (CR-2)
            starredAt: Value(seed.starred ? now : null),
            heatmapLabel: Value(seed.heatmapLabel),
            heatmapRule: Value(seed.heatmapRule),
            sortOrder: Value(order++),
            unit: Value(seed.unit),
            createdAt: now,
            updatedAt: now,
          ),
        );
        idsByKey[seed.key] = id;
        for (var i = 0; i < seed.options.length; i++) {
          await into(metricOptions).insert(
            MetricOptionsCompanion.insert(
              metricId: id,
              label: seed.options[i],
              sortOrder: Value(i),
            ),
          );
        }
      }
      for (final entry in seedSettings.entries) {
        await into(appSettings).insert(
          AppSettingsCompanion.insert(key: entry.key, value: entry.value),
        );
      }
    });
  }
}

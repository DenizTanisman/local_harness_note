import 'package:drift/drift.dart';

import 'seed_data.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Metrics,
  MetricOptions,
  Entries,
  EntryOptions,
  Transactions,
  MoneyCategories,
  ExpenseReminders,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE INDEX idx_entries_date ON entries(date)');
          await customStatement(
              'CREATE INDEX idx_tx_date ON transactions(date)');
          await customStatement(
              'CREATE INDEX idx_metrics_parent ON metrics(parent_id)');
          await _seed();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Debounced auto-save target (spec 6.2): one row per metric × day.
  /// On conflict the value columns are updated; created_at is preserved.
  Future<int> upsertEntry(EntriesCompanion entry) {
    return into(entries).insert(
      entry,
      onConflict: DoUpdate(
        (old) => EntriesCompanion(
          numValue: entry.numValue,
          textValue: entry.textValue,
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
        final id = await into(metrics).insert(MetricsCompanion.insert(
          parentId: Value(
              seed.parentKey == null ? null : idsByKey[seed.parentKey]!),
          key: seed.key,
          title: seed.title,
          inputType: seed.inputType,
          isStarred: Value(seed.starred),
          starredAt: Value(seed.starred ? now : null),
          heatmapLabel: Value(seed.heatmapLabel),
          heatmapRule: Value(seed.heatmapRule),
          sortOrder: Value(order++),
          unit: Value(seed.unit),
          createdAt: now,
          updatedAt: now,
        ));
        idsByKey[seed.key] = id;
        for (var i = 0; i < seed.options.length; i++) {
          await into(metricOptions).insert(MetricOptionsCompanion.insert(
            metricId: id,
            label: seed.options[i],
            sortOrder: Value(i),
          ));
        }
      }
      for (var i = 0; i < seedMoneyCategories.length; i++) {
        final c = seedMoneyCategories[i];
        await into(moneyCategories).insert(MoneyCategoriesCompanion.insert(
          direction: c.direction,
          name: c.name,
          isEssential: Value(c.essential),
          countsInHeatmap: Value(c.countsInHeatmap),
          sortOrder: Value(i),
        ));
      }
      for (final entry in seedSettings.entries) {
        await into(appSettings).insert(
            AppSettingsCompanion.insert(key: entry.key, value: entry.value));
      }
    });
  }
}

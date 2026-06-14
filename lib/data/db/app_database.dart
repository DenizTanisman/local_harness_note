import 'package:drift/drift.dart';

import 'seed_data.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Metrics,
    MetricOptions,
    Entries,
    EntryOptions,
    Transactions,
    MoneyCategories,
    ExpenseReminders,
    AppSettings,
    HealthProfile,
    BodyLog,
    HealthSamples,
    SyncState,
    SavedExerciseTitles,
    SavedFoodTypes,
    Programs,
    ProgramExercises,
    CalorieEntries,
    CalorieDay,
    ProgramLog,
    ScreenTimeDay,
    ScreenTimeApp,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('CREATE INDEX idx_entries_date ON entries(date)');
      await customStatement('CREATE INDEX idx_tx_date ON transactions(date)');
      await customStatement(
        'CREATE INDEX idx_metrics_parent ON metrics(parent_id)',
      );
      await _seed();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // CR-2: existing installs — protect the core 12 by KEY
        // (never by id; the user may have reordered).
        await markCoreUndeletable();
      }
      if (from < 3) {
        // Promotion memory for drop-grouped leaves (demote-on-detach fix).
        await m.addColumn(metrics, metrics.prevInputType);
      }
      if (from < 4) {
        // Repair cards damaged by pre-v3 promotions (no prev_input_type
        // memory existed): restore core types from the seed definitions.
        await repairCorruptedCoreTypes();
      }
      if (from < 5) {
        // CR-3 Health tables.
        await m.createTable(healthProfile);
        await m.createTable(bodyLog);
        await m.createTable(healthSamples);
        await m.createTable(syncState);
      }
      if (from < 6) {
        // CR-3 Sport + calorie tables.
        await m.createTable(savedExerciseTitles);
        await m.createTable(savedFoodTypes);
        await m.createTable(programs);
        await m.createTable(programExercises);
        await m.createTable(calorieEntries);
        await m.createTable(calorieDay);
        await m.createTable(programLog);
        await _seedFoodTypes();
      }
      if (from < 7) {
        // CR-4 screen-time tables.
        await m.createTable(screenTimeDay);
        await m.createTable(screenTimeApp);
      }
      if (from < 8) {
        // CR-4 §3.3 Instagram auto-fill provenance.
        await m.addColumn(entries, entries.valueSource);
      }
      if (from < 9) {
        // Recolor the core heatmap rules to the modern blue scheme and
        // refresh the Waste option label to 'Energy Waste'.
        await applyBlueHeatmapRules();
      }
      if (from < 10) {
        // Calorie redesign: saved foods carry a category + per-unit calories,
        // and an entry covers a quantity (×N).
        await m.addColumn(savedFoodTypes, savedFoodTypes.category);
        await m.addColumn(savedFoodTypes, savedFoodTypes.kcalPerUnit);
        await m.addColumn(calorieEntries, calorieEntries.quantity);
      }
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

  /// v4 repair: a leaf promoted to composite BEFORE v3 carries no
  /// prev_input_type, so demote-on-detach cannot restore it. Core metric
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

  /// v9 migration body, exposed for tests: rewrite the seeded heatmap rules
  /// to their current (blue) definitions and rename the Waste option.
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

  /// CR-2 v2 migration body, exposed for tests.
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
            isDeletable: const Value(false), // core 12 protected (CR-2)
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
      for (var i = 0; i < seedMoneyCategories.length; i++) {
        final c = seedMoneyCategories[i];
        await into(moneyCategories).insert(
          MoneyCategoriesCompanion.insert(
            direction: c.direction,
            name: c.name,
            isEssential: Value(c.essential),
            countsInHeatmap: Value(c.countsInHeatmap),
            sortOrder: Value(i),
          ),
        );
      }
      for (final entry in seedSettings.entries) {
        await into(appSettings).insert(
          AppSettingsCompanion.insert(key: entry.key, value: entry.value),
        );
      }
    });
    await _seedFoodTypes();
  }

  /// Built-in food types (CR-3 §12). Idempotent — safe in onCreate and the
  /// v6 upgrade.
  Future<void> _seedFoodTypes() async {
    for (final name in ['Food', 'FastFood', 'Drink', 'Veg&Fruit']) {
      await into(savedFoodTypes).insert(
        SavedFoodTypesCompanion.insert(
          name: name,
          isBuiltin: const Value(true),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }
}

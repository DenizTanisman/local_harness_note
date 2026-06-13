import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Read/write access for the home entry screen (spec 6.2).
class EntryRepository {
  EntryRepository(this.db);

  final AppDatabase db;

  // ---------- metrics ----------

  /// Top-level cards in sort order.
  Stream<List<Metric>> watchTopLevelMetrics() {
    final query = db.select(db.metrics)
      ..where((m) => m.parentId.isNull())
      ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]);
    return query.watch();
  }

  /// Children of a composite group in sort order.
  Stream<List<Metric>> watchChildren(int parentId) {
    final query = db.select(db.metrics)
      ..where((m) => m.parentId.equals(parentId))
      ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]);
    return query.watch();
  }

  Stream<List<MetricOption>> watchOptions(int metricId) {
    final query = db.select(db.metricOptions)
      ..where((o) => o.metricId.equals(metricId))
      ..orderBy([(o) => OrderingTerm.asc(o.sortOrder)]);
    return query.watch();
  }

  /// Slugified unique key from a user title ('My Habit!' → 'my_habit').
  Future<String> uniqueKeyFor(String title) async {
    var base = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (base.isEmpty) base = 'metric';
    final taken = (await db.select(db.metrics).get()).map((m) => m.key).toSet();
    var candidate = base;
    var i = 2;
    while (taken.contains(candidate)) {
      candidate = '${base}_${i++}';
    }
    return candidate;
  }

  /// ADD flow (spec 6.2): appended to the end of the list, unstarred.
  Future<int> addMetric({
    required String title,
    required String inputType,
    List<String> options = const [],
  }) async {
    return db.transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final maxOrder = await _maxSortOrder();
      final id = await db
          .into(db.metrics)
          .insert(
            MetricsCompanion.insert(
              key: await uniqueKeyFor(title),
              title: title,
              inputType: inputType,
              sortOrder: Value(maxOrder + 1),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (var i = 0; i < options.length; i++) {
        await db
            .into(db.metricOptions)
            .insert(
              MetricOptionsCompanion.insert(
                metricId: id,
                label: options[i],
                sortOrder: Value(i),
              ),
            );
      }
      return id;
    });
  }

  Future<int> _maxSortOrder() async {
    final max = db.metrics.sortOrder.max();
    final row = await (db.selectOnly(
      db.metrics,
    )..addColumns([max])).getSingle();
    return row.read(max) ?? 0;
  }

  /// Del flow: removes the metric and its whole history (CASCADE).
  /// Core metrics are refused here too — the UI condition alone is not a
  /// guarantee against future flows like swipe-to-delete (CR-2).
  Future<void> deleteMetric(int metricId) async {
    final metric = await (db.select(
      db.metrics,
    )..where((m) => m.id.equals(metricId))).getSingleOrNull();
    if (metric == null) return;
    if (!metric.isDeletable) {
      throw StateError('Core metric "${metric.key}" cannot be deleted');
    }
    await (db.delete(db.metrics)..where((m) => m.id.equals(metricId))).go();
    // Deleting the last child of a promoted group restores the parent's
    // original input type.
    if (metric.parentId != null) {
      await db.demoteIfChildless(metric.parentId!);
    }
  }

  // ---------- entries ----------

  /// All entries of [date], keyed by metric id.
  Stream<Map<int, Entry>> watchEntriesFor(String date) {
    final query = db.select(db.entries)..where((e) => e.date.equals(date));
    return query.watch().map((rows) => {for (final e in rows) e.metricId: e});
  }

  /// Selected option ids of [date], keyed by metric id.
  Stream<Map<int, Set<int>>> watchSelectedOptionsFor(String date) {
    final join = db.select(db.entryOptions).join([
      innerJoin(db.entries, db.entries.id.equalsExp(db.entryOptions.entryId)),
      innerJoin(
        db.metricOptions,
        db.metricOptions.id.equalsExp(db.entryOptions.optionId),
      ),
    ])..where(db.entries.date.equals(date));
    return join.watch().map((rows) {
      final result = <int, Set<int>>{};
      for (final row in rows) {
        final entry = row.readTable(db.entries);
        final option = row.readTable(db.metricOptions);
        result.putIfAbsent(entry.metricId, () => {}).add(option.id);
      }
      return result;
    });
  }

  /// Whether the Money card should count as "unfilled" (spec 6.2): no
  /// transactions that day.
  Stream<bool> watchHasTransactions(String date) {
    final count = db.transactions.id.count();
    final query = db.selectOnly(db.transactions)
      ..addColumns([count])
      ..where(db.transactions.date.equals(date));
    return query.watchSingle().map((row) => (row.read(count) ?? 0) > 0);
  }

  /// Debounce target — single upsert keeps one row per metric × day. A
  /// save through this path is a MANUAL edit, so it pins value_source =
  /// 'manual' (CR-4 §3.3) and screen-time auto-fill won't overwrite it.
  Future<void> saveEntry({
    required int metricId,
    required String date,
    double? numValue,
    String? textValue,
    bool keepExistingNum = false,
    bool keepExistingText = false,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await _entryFor(metricId, date);
    if (existing != null) {
      await (db.update(
        db.entries,
      )..where((e) => e.id.equals(existing.id))).write(
        EntriesCompanion(
          numValue: keepExistingNum ? const Value.absent() : Value(numValue),
          textValue: keepExistingText ? const Value.absent() : Value(textValue),
          valueSource: const Value('manual'),
          updatedAt: Value(now),
        ),
      );
    } else {
      await db.upsertEntry(
        EntriesCompanion.insert(
          metricId: metricId,
          date: date,
          numValue: Value(numValue),
          textValue: Value(textValue),
          valueSource: const Value('manual'),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  /// Screen-time auto-fill for the Instagram metric (CR-4 §3.3): writes the
  /// measured [minutes] into that day's num_value ONLY when there is no
  /// entry yet or the existing entry is itself auto. A manual edit wins and
  /// is never overwritten. The free-text "why" (text_value) is preserved.
  /// Returns true if it wrote.
  Future<bool> autofillInstagram({
    required String date,
    required double minutes,
  }) async {
    final metric = await (db.select(
      db.metrics,
    )..where((m) => m.key.equals('instagram'))).getSingleOrNull();
    if (metric == null) return false;
    final existing = await _entryFor(metric.id, date);
    if (existing != null && existing.valueSource != 'auto') return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (existing != null) {
      await (db.update(
        db.entries,
      )..where((e) => e.id.equals(existing.id))).write(
        EntriesCompanion(
          numValue: Value(minutes),
          valueSource: const Value('auto'),
          updatedAt: Value(now),
        ),
      );
    } else {
      await db.upsertEntry(
        EntriesCompanion.insert(
          metricId: metric.id,
          date: date,
          numValue: Value(minutes),
          valueSource: const Value('auto'),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    return true;
  }

  Future<Entry?> _entryFor(int metricId, String date) =>
      (db.select(db.entries)
            ..where((e) => e.metricId.equals(metricId) & e.date.equals(date)))
          .getSingleOrNull();

  /// Removes the day's entry entirely (composite child toggled off).
  Future<void> clearEntry(int metricId, String date) => (db.delete(
    db.entries,
  )..where((e) => e.metricId.equals(metricId) & e.date.equals(date))).go();

  /// Toggles a checkbox option, creating the day entry on demand.
  Future<void> setOptionSelected({
    required int metricId,
    required int optionId,
    required String date,
    required bool selected,
  }) async {
    await db.transaction(() async {
      var entry = await _entryFor(metricId, date);
      if (entry == null) {
        if (!selected) return;
        await saveEntry(metricId: metricId, date: date);
        entry = await _entryFor(metricId, date);
      }
      if (selected) {
        await db
            .into(db.entryOptions)
            .insert(
              EntryOptionsCompanion.insert(
                entryId: entry!.id,
                optionId: optionId,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      } else {
        await (db.delete(db.entryOptions)..where(
              (eo) =>
                  eo.entryId.equals(entry!.id) & eo.optionId.equals(optionId),
            ))
            .go();
      }
    });
  }
}

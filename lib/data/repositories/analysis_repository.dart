import 'package:drift/drift.dart';

import '../../core/date_key.dart';
import '../db/app_database.dart';
import '../db/seed_data.dart';
import '../heatmap/heatmap_rule.dart';

/// All values needed to paint the heatmap window (spec §5).
class HeatmapMatrix {
  const HeatmapMatrix({
    required this.metrics,
    required this.dates,
    required this.values,
    required this.rules,
  });

  /// Rows, already in display order (core 8 fixed, then star order).
  final List<Metric> metrics;

  /// Columns, oldest → newest ('YYYY-MM-DD').
  final List<String> dates;

  /// metricId → date → value; null/missing = no data that day (empty cell).
  final Map<int, Map<String, double>> values;

  final Map<int, HeatmapRule> rules;
}

/// One node of the recursive daily breakdown tree (CR1-A).
/// Roots are always visible; every deeper level starts collapsed.
class BreakdownNode {
  const BreakdownNode({
    required this.id,
    required this.title,
    this.metric,
    this.inlineExpand = false,
    this.children = const [],
  });

  /// Stable path id ('development/dev_social/note') — keys the expansion
  /// state.
  final String id;

  /// Full row text, e.g. 'Software: 45 min'.
  final String title;

  /// Tapping the TITLE opens this metric's page (arrow toggles instead).
  final Metric? metric;

  /// Long-text leaf: the arrow un-ellipsizes the title (Software notes).
  final bool inlineExpand;

  final List<BreakdownNode> children;

  bool get hasArrow => inlineExpand || children.isNotEmpty;
}

class AnalysisRepository {
  AnalysisRepository(this.db);

  final AppDatabase db;

  /// Re-emits whenever any table involved in analysis changes.
  Stream<void> _changes() => db
      .customSelect(
        'SELECT 1',
        readsFrom: {
          db.metrics,
          db.metricOptions,
          db.entries,
          db.entryOptions,
        },
      )
      .watch()
      .map((_) {});

  Stream<HeatmapMatrix> watchHeatmap(
    String endDate,
    int days, {
    String Function(String key)? floorFor,
    String? todayKey,
  }) => _changes().asyncMap(
    (_) => loadHeatmap(endDate, days, floorFor: floorFor, todayKey: todayKey),
  );

  /// Starred rows in display order: the core 8 first (fixed order), then
  /// later-starred metrics by star time (spec 5.3).
  Future<List<Metric>> starredInDisplayOrder() async {
    final starred = await (db.select(
      db.metrics,
    )..where((m) => m.isStarred.equals(true))).get();
    final coreIndex = {
      for (var i = 0; i < coreHeatmapOrder.length; i++) coreHeatmapOrder[i]: i,
    };
    starred.sort((a, b) {
      final ai = coreIndex[a.key];
      final bi = coreIndex[b.key];
      if (ai != null && bi != null) return ai.compareTo(bi);
      if (ai != null) return -1;
      if (bi != null) return 1;
      final at = a.starredAt ?? a.createdAt;
      final bt = b.starredAt ?? b.createdAt;
      final cmp = at.compareTo(bt);
      return cmp != 0 ? cmp : a.id.compareTo(b.id);
    });
    return starred;
  }

  /// [floorFor] gives each metric the first date it has data for; days
  /// before it stay EMPTY (no zero-fill) — tracking hadn't started. Days
  /// after [todayKey] are also empty (the future hasn't happened). Defaults
  /// are permissive (no floor / no future cap) so repository tests keep
  /// exercising the plain zero-fill; the app passes the real config.
  Future<HeatmapMatrix> loadHeatmap(
    String endDate,
    int days, {
    String Function(String key)? floorFor,
    String? todayKey,
  }) async {
    final floor = floorFor ?? (_) => '0000-01-01';
    final today = todayKey ?? '9999-12-31';
    final metrics = await starredInDisplayOrder();
    final end = parseDateKey(endDate);
    final dates = [
      for (var i = days - 1; i >= 0; i--)
        dateKey(end.subtract(Duration(days: i))),
    ];
    final startDate = dates.first;

    final rules = <int, HeatmapRule>{};
    for (final metric in metrics) {
      if (metric.heatmapRule != null) {
        rules[metric.id] = HeatmapRule.decode(metric.heatmapRule!);
      }
    }

    final values = <int, Map<String, double>>{};
    for (final metric in metrics) {
      final rule = rules[metric.id];
      if (rule == null) continue;
      final present = await sourceValues(
        metric,
        rule.source,
        startDate,
        endDate,
      );
      final metricFloor = floor(metric.key);
      // End-of-day-zero rule: within the tracked window a blank day counts
      // as 0 (Waste/checkbox = NO). Outside it — before the metric's data
      // floor or after today — the cell is omitted (empty), not zero.
      values[metric.id] = {
        for (final d in dates)
          if (d.compareTo(metricFloor) >= 0 && d.compareTo(today) <= 0)
            d: present[d] ?? 0.0,
      };
    }
    return HeatmapMatrix(
      metrics: metrics,
      dates: dates,
      values: values,
      rules: rules,
    );
  }

  /// Day → value for one metric in [startDate, endDate]; days without data
  /// are absent. Shared by the heatmap and the detail page.
  Future<Map<String, double>> sourceValues(
    Metric metric,
    HeatmapSource source,
    String startDate,
    String endDate,
  ) async {
    switch (source) {
      case HeatmapSource.numValue:
      case HeatmapSource.textExists:
        final rows =
            await (db.select(db.entries)..where(
                  (e) =>
                      e.metricId.equals(metric.id) &
                      e.date.isBetweenValues(startDate, endDate),
                ))
                .get();
        if (source == HeatmapSource.numValue) {
          return {
            for (final e in rows)
              if (e.numValue != null) e.date: e.numValue!,
          };
        }
        return {
          for (final e in rows)
            e.date: (e.textValue?.trim().isNotEmpty ?? false) ? 1 : 0,
        };

      case HeatmapSource.optionCount:
        final count = db.entryOptions.optionId.count();
        final query = db.selectOnly(db.entries)
          ..addColumns([db.entries.date, count])
          ..join([
            leftOuterJoin(
              db.entryOptions,
              db.entryOptions.entryId.equalsExp(db.entries.id),
            ),
          ])
          ..where(
            db.entries.metricId.equals(metric.id) &
                db.entries.date.isBetweenValues(startDate, endDate),
          )
          ..groupBy([db.entries.date]);
        final rows = await query.get();
        return {
          for (final row in rows)
            row.read(db.entries.date)!: (row.read(count) ?? 0).toDouble(),
        };

      case HeatmapSource.filledSubcount:
        final children = db.alias(db.metrics, 'children');
        final count = db.entries.id.count();
        final query = db.selectOnly(db.entries)
          ..addColumns([db.entries.date, count])
          ..join([
            innerJoin(children, children.id.equalsExp(db.entries.metricId)),
          ])
          ..where(
            children.parentId.equals(metric.id) &
                db.entries.date.isBetweenValues(startDate, endDate),
          )
          ..groupBy([db.entries.date]);
        final rows = await query.get();
        return {
          for (final row in rows)
            row.read(db.entries.date)!: (row.read(count) ?? 0).toDouble(),
        };
    }
  }

  // ---------- daily breakdown (spec 6.3) ----------

  Stream<List<BreakdownNode>> watchBreakdown(String date) =>
      _changes().asyncMap((_) => loadBreakdown(date));

  /// Root nodes in card order. Children follow CR1-A:
  /// composite → filled child → its text; text metrics → note leaf.
  Future<List<BreakdownNode>> loadBreakdown(String date) async {
    final top =
        await (db.select(db.metrics)
              ..where((m) => m.parentId.isNull())
              ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
            .get();
    final entries = await (db.select(
      db.entries,
    )..where((e) => e.date.equals(date))).get();
    final byMetric = {for (final e in entries) e.metricId: e};

    final roots = <BreakdownNode>[];
    for (final metric in top) {
      switch (metric.inputType) {
        case 'composite':
          final node = await _compositeBreakdown(metric, byMetric);
          if (node != null) roots.add(node);
        case 'checkbox':
          final entry = byMetric[metric.id];
          if (entry == null) break;
          final labels = await _selectedLabels(entry.id);
          roots.add(
            BreakdownNode(
              id: metric.key,
              title:
                  '${metric.title}: ${labels.isEmpty ? '—' : labels.join(', ')}',
              metric: metric,
            ),
          );
        default:
          final entry = byMetric[metric.id];
          if (entry == null) break;
          final text = entry.textValue?.trim();
          roots.add(
            BreakdownNode(
              id: metric.key,
              title: '${metric.title}: ${_formatValue(metric, entry)}',
              metric: metric,
              children: [
                if (text != null && text.isNotEmpty)
                  BreakdownNode(
                    id: '${metric.key}/note',
                    title: text,
                    inlineExpand: true,
                  ),
              ],
            ),
          );
      }
    }
    return roots;
  }

  Future<List<String>> _selectedLabels(int entryId) async {
    final join = db.select(db.metricOptions).join([
      innerJoin(
        db.entryOptions,
        db.entryOptions.optionId.equalsExp(db.metricOptions.id),
      ),
    ])..where(db.entryOptions.entryId.equals(entryId));
    final rows = await join.get();
    return [for (final r in rows) r.readTable(db.metricOptions).label];
  }

  Future<BreakdownNode?> _compositeBreakdown(
    Metric metric,
    Map<int, Entry> dayEntries,
  ) async {
    final children =
        await (db.select(db.metrics)
              ..where((m) => m.parentId.equals(metric.id))
              ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
            .get();
    final filled = [
      for (final child in children)
        if (dayEntries.containsKey(child.id)) child,
    ];
    // group_display: 'sub_names' lists filled child names; 'own_value'
    // shows the group's own entry value (spec 6.3).
    final ownEntry = dayEntries[metric.id];
    if (filled.isEmpty && ownEntry == null) return null; // nothing that day
    final valueText = metric.groupDisplay == 'own_value'
        ? (ownEntry != null ? _formatValue(metric, ownEntry) : '—')
        : (filled.isEmpty ? '—' : filled.map((c) => c.title).join(', '));
    return BreakdownNode(
      id: metric.key,
      title: '${metric.title}: $valueText',
      metric: metric,
      children: [
        for (final child in filled)
          BreakdownNode(
            id: '${metric.key}/${child.key}',
            title: child.title,
            metric: child,
            children: [
              if (dayEntries[child.id]?.textValue?.trim().isNotEmpty ?? false)
                BreakdownNode(
                  id: '${metric.key}/${child.key}/note',
                  title: dayEntries[child.id]!.textValue!,
                ),
            ],
          ),
      ],
    );
  }

  String _formatValue(Metric metric, Entry entry) {
    if (entry.numValue != null) {
      final v = entry.numValue!;
      final text = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
      return metric.unit != null ? '$text ${metric.unit}' : text;
    }
    if (entry.textValue?.trim().isNotEmpty ?? false) return '✓';
    return '—';
  }
}

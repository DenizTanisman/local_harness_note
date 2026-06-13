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

  /// Rows, already in display order (core 9 fixed, then star order).
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

  /// Stable path id ('money/outcome/Food') — keys the expansion state.
  final String id;

  /// Full row text, e.g. 'Outcome (Month): 200'.
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
          db.transactions,
          db.moneyCategories,
        },
      )
      .watch()
      .map((_) {});

  Stream<HeatmapMatrix> watchHeatmap(String endDate, int days) =>
      _changes().asyncMap((_) => loadHeatmap(endDate, days));

  /// Starred rows in display order: the core 9 first (fixed order), then
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

  Future<HeatmapMatrix> loadHeatmap(String endDate, int days) async {
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
      // End-of-day-zero rule: a day with no entry counts as 0 (Waste/
      // checkbox = NO = 0 options). Every cell in the window is ≤ the
      // selected date, so all get a real value and are colored by the 0
      // bucket instead of shown as an empty cell.
      values[metric.id] = {for (final d in dates) d: present[d] ?? 0.0};
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

      case HeatmapSource.txSumHeatmap:
        final sum = db.transactions.amount.sum();
        final query = db.selectOnly(db.transactions)
          ..addColumns([db.transactions.date, sum])
          ..join([
            innerJoin(
              db.moneyCategories,
              db.moneyCategories.name.equalsExp(db.transactions.category) &
                  db.moneyCategories.direction.equalsExp(
                    db.transactions.direction,
                  ),
            ),
          ])
          ..where(
            db.transactions.direction.equals('outcome') &
                db.moneyCategories.countsInHeatmap.equals(true) &
                db.transactions.date.isBetweenValues(startDate, endDate),
          )
          ..groupBy([db.transactions.date]);
        final rows = await query.get();
        final result = {
          for (final row in rows)
            row.read(db.transactions.date)!: row.read(sum) ?? 0.0,
        };
        // A day with any transaction is "filled" even if nothing counts
        // toward the heatmap sum (sum 0 → darkGreen bucket).
        final txDays =
            await (db.selectOnly(db.transactions, distinct: true)
                  ..addColumns([db.transactions.date])
                  ..where(
                    db.transactions.date.isBetweenValues(startDate, endDate),
                  ))
                .get();
        for (final row in txDays) {
          result.putIfAbsent(row.read(db.transactions.date)!, () => 0.0);
        }
        return result;
    }
  }

  // ---------- daily breakdown (spec 6.3) ----------

  Stream<List<BreakdownNode>> watchBreakdown(String date) =>
      _changes().asyncMap((_) => loadBreakdown(date));

  /// Root nodes in card order. Children follow CR1-A:
  /// Money → Income/Outcome (Month) → category → subtype;
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
        case 'money':
          roots.add(await _moneyBreakdown(metric, date));
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

  Future<BreakdownNode> _moneyBreakdown(Metric metric, String date) async {
    // Daily line: ALL outcome of the day — deliberately not the heatmap
    // filter (spec §9.5).
    final daySum = db.transactions.amount.sum();
    final dayRow =
        await (db.selectOnly(db.transactions)
              ..addColumns([daySum])
              ..where(
                db.transactions.date.equals(date) &
                    db.transactions.direction.equals('outcome'),
              ))
            .getSingle();
    final dayTotal = dayRow.read(daySum) ?? 0.0;

    final monthPrefix = date.substring(0, 7); // 'YYYY-MM'
    final sum = db.transactions.amount.sum();
    // Three levels: direction → category → subtype (CR1-A).
    final monthly =
        await (db.selectOnly(db.transactions)
              ..addColumns([
                db.transactions.direction,
                db.transactions.category,
                db.transactions.subtype,
                sum,
              ])
              ..where(db.transactions.date.like('$monthPrefix-%'))
              ..groupBy([
                db.transactions.direction,
                db.transactions.category,
                db.transactions.subtype,
              ])
              ..orderBy([OrderingTerm.desc(sum)]))
            .get();

    final directionNodes = <BreakdownNode>[];
    for (final direction in ['income', 'outcome']) {
      final rows = monthly
          .where((r) => r.read(db.transactions.direction) == direction)
          .toList();
      final byCategory = <String, double>{};
      final subtypes = <String, List<({String label, double total})>>{};
      for (final r in rows) {
        final category = r.read(db.transactions.category)!;
        final amount = r.read(sum) ?? 0;
        byCategory[category] = (byCategory[category] ?? 0) + amount;
        final subtype = r.read(db.transactions.subtype);
        if (subtype != null) {
          subtypes.putIfAbsent(category, () => []).add((
            label: '$category ($subtype)',
            total: amount,
          ));
        }
      }
      final total = byCategory.values.fold<double>(0, (acc, v) => acc + v);
      final label = direction == 'outcome' ? 'Outcome' : 'Income';
      final names = byCategory.keys.toList()
        ..sort((a, b) => byCategory[b]!.compareTo(byCategory[a]!));
      directionNodes.add(
        BreakdownNode(
          id: 'money/$direction',
          title: '$label (Month): ${formatAmount(total)}',
          metric: metric,
          children: [
            for (final name in names)
              BreakdownNode(
                id: 'money/$direction/$name',
                title: '$name: ${formatAmount(byCategory[name]!)}',
                metric: metric,
                children: [
                  for (final sub in subtypes[name] ?? const [])
                    BreakdownNode(
                      id: 'money/$direction/$name/${sub.label}',
                      title: '${sub.label}: ${formatAmount(sub.total)}',
                      metric: metric,
                    ),
                ],
              ),
          ],
        ),
      );
    }
    return BreakdownNode(
      id: 'money',
      title: '${metric.title}: ${formatAmount(dayTotal)} ${metric.unit ?? ''}'
          .trim(),
      metric: metric,
      children: directionNodes,
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

/// 12300.0 → '12.300' (tr-style thousands separator, no decimals when whole).
String formatAmount(double value) {
  final whole = value == value.roundToDouble();
  final text = whole ? value.toInt().toString() : value.toStringAsFixed(2);
  final parts = text.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0 && digits[i - 1] != '-') {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return parts.length > 1 ? '$buffer,${parts[1]}' : buffer.toString();
}

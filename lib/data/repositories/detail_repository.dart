import '../../core/date_key.dart';
import '../db/app_database.dart';
import '../heatmap/heatmap_rule.dart';
import 'analysis_repository.dart';

/// Month series + Daily/Weekly/Monthly stats for the detail page (spec 6.4).
class DetailStats {
  const DetailStats({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  final double daily;
  final double weekly;

  /// Sums for numeric metrics (spec open point #4).
  final double monthly;
}

class MonthSeries {
  const MonthSeries({required this.month, required this.values});

  /// 'YYYY-MM'.
  final String month;

  /// Day of month (1-based) → value; missing day = no data.
  final Map<int, double> values;

  int get daysInMonth {
    final parts = month.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1] + 1, 0).day;
  }
}

class DetailRepository {
  DetailRepository(this.db);

  final AppDatabase db;
  late final AnalysisRepository _analysis = AnalysisRepository(db);

  /// The value source for a metric: its heatmap rule's source, or a
  /// sensible default from the input type when it has none.
  HeatmapSource sourceFor(Metric metric) {
    if (metric.heatmapRule != null) {
      return HeatmapRule.decode(metric.heatmapRule!).source;
    }
    switch (metric.inputType) {
      case 'text':
        return HeatmapSource.textExists;
      case 'checkbox':
        return HeatmapSource.optionCount;
      case 'composite':
        return HeatmapSource.filledSubcount;
      default:
        return HeatmapSource.numValue;
    }
  }

  Stream<MonthSeries> watchMonthSeries(Metric metric, String month) => db
      .customSelect(
        'SELECT 1',
        readsFrom: {
          db.entries,
          db.entryOptions,
          db.metrics,
        },
      )
      .watch()
      .asyncMap((_) => loadMonthSeries(metric, month));

  /// [month] is 'YYYY-MM'; the window covers exactly that month
  /// (28–31 days, spec 6.4).
  Future<MonthSeries> loadMonthSeries(Metric metric, String month) async {
    final parts = month.split('-').map(int.parse).toList();
    final lastDay = DateTime(parts[0], parts[1] + 1, 0).day;
    final start = '$month-01';
    final end = '$month-${lastDay.toString().padLeft(2, '0')}';
    final values = await _analysis.sourceValues(
      metric,
      sourceFor(metric),
      start,
      end,
    );
    return MonthSeries(
      month: month,
      values: {
        for (final entry in values.entries)
          int.parse(entry.key.substring(8)): entry.value,
      },
    );
  }

  /// Daily value + weekly (Mon–Sun week of [date]) and monthly sums.
  Future<DetailStats> loadStats(Metric metric, String date) async {
    final source = sourceFor(metric);
    final day = parseDateKey(date);
    final weekStart = day.subtract(Duration(days: day.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final monthLast = DateTime(day.year, day.month + 1, 0);

    final windowStart = dateKey(
      weekStart.isBefore(DateTime(day.year, day.month, 1))
          ? weekStart
          : DateTime(day.year, day.month, 1),
    );
    final windowEnd = dateKey(weekEnd.isAfter(monthLast) ? weekEnd : monthLast);

    final values = await _analysis.sourceValues(
      metric,
      source,
      windowStart,
      windowEnd,
    );

    double sumBetween(DateTime start, DateTime end) {
      var sum = 0.0;
      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        sum += values[dateKey(d)] ?? 0;
      }
      return sum;
    }

    return DetailStats(
      daily: values[date] ?? 0,
      weekly: sumBetween(weekStart, weekEnd),
      monthly: sumBetween(DateTime(day.year, day.month, 1), monthLast),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/detail_repository.dart';
import '../analysis/analysis_providers.dart';
import '../shared/calendar_row.dart';
import '../shared/continuous_sparkline.dart';

final detailRepositoryProvider = Provider<DetailRepository>(
    (ref) => DetailRepository(ref.watch(databaseProvider)));

/// Month window follows the selected date (spec 6.4).
final monthSeriesProvider =
    StreamProvider.family<MonthSeries, Metric>((ref, metric) {
  final month = ref.watch(selectedDateProvider).substring(0, 7);
  return ref.watch(detailRepositoryProvider).watchMonthSeries(metric, month);
});

final detailStatsProvider =
    FutureProvider.family<DetailStats, Metric>((ref, metric) {
  // Re-read when the month series re-emits (any underlying table change).
  ref.watch(monthSeriesProvider(metric));
  final date = ref.watch(selectedDateProvider);
  return ref.watch(detailRepositoryProvider).loadStats(metric, date);
});

/// Template detail page for every leaf metric (spec 6.4).
class MetricDetailPage extends ConsumerWidget {
  const MetricDetailPage({super.key, required this.metric});

  final Metric metric;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(monthSeriesProvider(metric));
    final stats = ref.watch(detailStatsProvider(metric));
    final date = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(metric.title)),
      body: ListView(
        children: [
          const CalendarRow(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: series.when(
              loading: () => const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
              data: (data) => ContinuousSparkline(
                daysInMonth: data.daysInMonth,
                values: data.values,
                selectedDay: int.parse(date.substring(8)),
                onDayTap: (day) {
                  final candidate =
                      '${data.month}-${day.toString().padLeft(2, '0')}';
                  ref.read(selectedDateProvider.notifier).select(candidate);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          stats.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('Error: $e'),
            data: (s) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statLine(context, 'Daily', s.daily),
                  _statLine(context, 'Weekly', s.weekly),
                  _statLine(context, 'Monthly', s.monthly),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statLine(BuildContext context, String label, double value) {
    final text =
        value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
    final unit = metric.unit != null ? ' ${metric.unit}' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: $text$unit',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}


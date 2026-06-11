import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/detail_repository.dart';
import '../analysis/analysis_providers.dart';
import '../shared/calendar_row.dart';

/// GitHub dark-mode neon green (spec 6.4).
const sparklineColor = Color(0xFF39D353);

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
              data: (data) => Sparkline(
                series: data,
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

/// Month-window sparkline drawn with a CustomPainter; dots are tappable
/// (spec 6.4).
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.series,
    required this.selectedDay,
    this.onDayTap,
  });

  final MonthSeries series;
  final int selectedDay;
  final void Function(int day)? onDayTap;

  static const height = 160.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        key: const ValueKey('sparkline'),
        onTapUp: (details) {
          final day = _dayAt(details.localPosition.dx, constraints.maxWidth);
          if (day != null) onDayTap?.call(day);
        },
        child: CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: SparklinePainter(
            series: series,
            selectedDay: selectedDay,
            gridColor:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  int? _dayAt(double dx, double width) {
    final days = series.daysInMonth;
    final step = width / (days - 1);
    final day = (dx / step).round() + 1;
    if (day < 1 || day > days) return null;
    return day;
  }
}

class SparklinePainter extends CustomPainter {
  SparklinePainter({
    required this.series,
    required this.selectedDay,
    required this.gridColor,
  });

  final MonthSeries series;
  final int selectedDay;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final days = series.daysInMonth;
    final values = series.values;
    final maxValue = values.values.isEmpty
        ? 1.0
        : values.values.reduce((a, b) => a > b ? a : b);
    final scale = maxValue == 0 ? 1.0 : maxValue;
    final step = size.width / (days - 1);
    final baseY = size.height - 14;

    Offset pointFor(int day, double value) => Offset(
          (day - 1) * step,
          baseY - (value / scale) * (size.height - 32),
        );

    // Faint horizontal grid (quarters) + baseline.
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var q = 0; q <= 2; q++) {
      final y = baseY - (size.height - 32) * (q + 1) / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y),
          grid..color = gridColor.withValues(alpha: 0.35));
    }
    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY),
        grid..color = gridColor);

    // Build contiguous segments (gaps in data break the line).
    final sortedDays = values.keys.toList()..sort();
    final segments = <List<Offset>>[];
    int? prevDay;
    for (final day in sortedDays) {
      final point = pointFor(day, values[day]!);
      if (prevDay == null || day != prevDay + 1) {
        segments.add([point]);
      } else {
        segments.last.add(point);
      }
      prevDay = day;
    }

    final glow = Paint()
      ..color = sparklineColor.withValues(alpha: 0.45)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final line = Paint()
      ..color = sparklineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final segment in segments) {
      final path = Path()..moveTo(segment.first.dx, segment.first.dy);
      for (final point in segment.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      if (segment.length > 1) {
        // GitHub-style area fill fading to the baseline.
        final area = Path.from(path)
          ..lineTo(segment.last.dx, baseY)
          ..lineTo(segment.first.dx, baseY)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sparklineColor.withValues(alpha: 0.30),
                sparklineColor.withValues(alpha: 0.02),
              ],
            ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
        );
        canvas.drawPath(path, glow);
      }
      canvas.drawPath(path, line);
    }

    final dot = Paint()..color = sparklineColor;
    for (final day in sortedDays) {
      final point = pointFor(day, values[day]!);
      if (day == selectedDay) {
        canvas.drawCircle(
            point,
            9,
            Paint()
              ..color = sparklineColor.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawCircle(point, 5, dot);
        canvas.drawCircle(
            point,
            7,
            Paint()
              ..color = sparklineColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
      } else {
        canvas.drawCircle(point, 3, dot);
      }
    }
  }

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) =>
      oldDelegate.series != series || oldDelegate.selectedDay != selectedDay;
}

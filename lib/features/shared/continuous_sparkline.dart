import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// GitHub dark-mode neon green — preserved by CR1-B rule 3.
const sparklineGreen = AppTokens.sparkline;

/// Day 1..N → value with missing/empty days as 0 (CR1-C: the line covers
/// the WHOLE month; no-data days run along the baseline).
List<double> filledMonthValues(int daysInMonth, Map<int, double> values) => [
  for (var d = 1; d <= daysInMonth; d++) values[d] ?? 0,
];

/// Color of a polyline segment. Segments are indexed by their left point
/// (0-based, so left point index i = day i+1); the segment belongs to the
/// day it RISES to — its right endpoint, day i+2. An over-budget Money day
/// therefore owns the segment reaching its peak.
Color segmentColor(int leftIndex, List<Color>? dayColors, Color fallback) {
  if (dayColors == null) return fallback;
  return dayColors[leftIndex + 2];
}

/// Continuous month sparkline (CR1-C): full-month polyline, flat baseline
/// for empty days, cheap glow (second wide pass, no blur), gradient fill,
/// no dots; a thin vertical marker shows the selected day.
class ContinuousSparkline extends StatelessWidget {
  const ContinuousSparkline({
    super.key,
    required this.daysInMonth,
    required this.values,
    required this.selectedDay,
    this.onDayTap,
    this.lineColor = sparklineGreen,
    this.dayColors,
    this.markerColor,
    this.height = 160,
  });

  final int daysInMonth;

  /// Day of month (1-based) → value; missing = 0.
  final Map<int, double> values;
  final int selectedDay;
  final void Function(int day)? onDayTap;
  final Color lineColor;

  /// Optional per-day line color (index 0 unused; 1..N), Money red/green.
  final List<Color>? dayColors;
  final Color? markerColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final marker =
        markerColor ??
        Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        key: const ValueKey('sparkline'),
        onTapUp: (details) {
          // Nearest day, clamped — taps at the edges never overflow the
          // month (CR1-C acceptance).
          final step = constraints.maxWidth / (daysInMonth - 1);
          final day = ((details.localPosition.dx / step).round() + 1).clamp(
            1,
            daysInMonth,
          );
          onDayTap?.call(day);
        },
        child: CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: ContinuousSparklinePainter(
            series: filledMonthValues(daysInMonth, values),
            selectedDay: selectedDay,
            lineColor: lineColor,
            dayColors: dayColors,
            markerColor: marker,
          ),
        ),
      ),
    );
  }
}

class ContinuousSparklinePainter extends CustomPainter {
  ContinuousSparklinePainter({
    required this.series,
    required this.selectedDay,
    required this.lineColor,
    required this.markerColor,
    this.dayColors,
  });

  /// Index 0 = day 1; zeros included — never empty for a valid month.
  final List<double> series;
  final int selectedDay;
  final Color lineColor;
  final Color markerColor;
  final List<Color>? dayColors;

  @override
  void paint(Canvas canvas, Size size) {
    final days = series.length;
    if (days < 2) return;
    final step = size.width / (days - 1);
    // Baseline fixed in the bottom 12% of the chart (CR1-C).
    final baseY = size.height * 0.88;
    const topPad = 8.0;
    final maxValue = series.reduce((a, b) => a > b ? a : b);

    Offset pointFor(int index) => Offset(
      index * step,
      maxValue == 0
          ? baseY
          : baseY - (series[index] / maxValue) * (baseY - topPad),
    );

    final points = [for (var i = 0; i < days; i++) pointFor(i)];

    // Selected-day vertical marker (1dp).
    final markerX = (selectedDay - 1).clamp(0, days - 1) * step;
    canvas.drawLine(
      Offset(markerX, topPad),
      Offset(markerX, size.height),
      Paint()
        ..color = markerColor
        ..strokeWidth = 1,
    );

    // Gradient fill under the whole contour.
    final area = Path()..moveTo(points.first.dx, baseY);
    for (final point in points) {
      area.lineTo(point.dx, point.dy);
    }
    area
      ..lineTo(points.last.dx, baseY)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.14),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Per-segment strokes: glow pass (6dp, 18% alpha, no blur — cheap),
    // then the 2dp contour. Money colors segments via dayColors.
    for (var i = 0; i < days - 1; i++) {
      final color = segmentColor(i, dayColors, lineColor);
      final glow = Paint()
        ..color = color.withValues(alpha: 0.18)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final line = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(points[i], points[i + 1], glow);
      canvas.drawLine(points[i], points[i + 1], line);
    }
  }

  @override
  bool shouldRepaint(ContinuousSparklinePainter oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.selectedDay != selectedDay ||
      oldDelegate.dayColors != dayColors;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/repositories/analysis_repository.dart' show formatAmount;
import '../../data/repositories/money_repository.dart';
import '../../theme/app_tokens.dart';
import 'money_reveal.dart';

/// Outcome-category donut for the Money Overview (CR-3 §4). CustomPainter,
/// no external chart package. Wrapped in a horizontal-drag absorber so a
/// drag on the chart never leaks to the global PageView swipe (§2/§4).
class CategoryDonut extends StatelessWidget {
  const CategoryDonut({super.key, required this.categories});

  final List<CategoryTotal> categories;

  @override
  Widget build(BuildContext context) {
    final total = categories.fold<double>(0, (a, c) => a + c.total);
    if (total <= 0) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No outcome this month.'),
      );
    }
    // Absorb horizontal drags so the chart doesn't switch tabs (CR-3 §4).
    return GestureDetector(
      key: const ValueKey('money-donut'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) {},
      onHorizontalDragUpdate: (_) {},
      onHorizontalDragEnd: (_) {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _DonutPainter(categories: categories, total: total),
                child: Center(
                  child: MoneyText(
                    id: 'money-donut-total',
                    amount: formatAmount(total),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < categories.length; i++)
                    _Legend(
                      color: AppTokens
                          .chartPalette[i % AppTokens.chartPalette.length],
                      label: categories[i].name,
                      value: categories[i].total,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          MoneyText(
            id: 'money-donut-$label',
            amount: formatAmount(value),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.categories, required this.total});

  final List<CategoryTotal> categories;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.shortestSide * 0.18;
    final inset = stroke / 2 + 2;
    final arcRect = rect.deflate(inset);
    var start = -math.pi / 2;
    for (var i = 0; i < categories.length; i++) {
      final sweep = (categories[i].total / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = AppTokens.chartPalette[i % AppTokens.chartPalette.length];
      // Tiny gap between slices for legibility.
      canvas.drawArc(arcRect, start + 0.02, sweep - 0.02, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.categories != categories || oldDelegate.total != total;
}

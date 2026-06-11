import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../theme/app_tokens.dart';
import '../../theme/heat_colors.dart';
import '../../data/repositories/analysis_repository.dart';
import 'analysis_providers.dart';

const _cellSize = 26.0;
const _cellGap = 3.0;
const _rowHeight = _cellSize + _cellGap;

/// Date label band above the grid.
const _dateBandHeight = 20.0;

/// Heatmap (spec §5): row per starred metric, column per day. Labels fixed
/// on the left (tap → detail page), grid horizontally scrollable, cell tap
/// selects that date.
class HeatmapWidget extends ConsumerStatefulWidget {
  const HeatmapWidget({super.key, this.onMetricTap});

  final void Function(Metric metric)? onMetricTap;

  @override
  ConsumerState<HeatmapWidget> createState() => _HeatmapWidgetState();
}

class _HeatmapWidgetState extends ConsumerState<HeatmapWidget> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matrix = ref.watch(heatmapProvider);
    return matrix.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Error: $e'),
      data: (data) {
        if (data.metrics.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Star a metric to see it here.'),
          );
        }
        // Newest day sits at the right edge on first build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients &&
              _scroll.position.maxScrollExtent > 0 &&
              _scroll.position.pixels == 0) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
        final height = data.metrics.length * _rowHeight + _dateBandHeight;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: _dateBandHeight),
                for (final metric in data.metrics)
                  InkWell(
                    key: ValueKey('heatmap-label-${metric.id}'),
                    onTap: () => widget.onMetricTap?.call(metric),
                    child: Container(
                      height: _rowHeight,
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      alignment: Alignment.centerRight,
                      child: Text(
                        metric.heatmapLabel ?? metric.title,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                child: GestureDetector(
                  onTapUp: (details) => _onTap(details.localPosition, data),
                  child: CustomPaint(
                    key: const ValueKey('heatmap-grid'),
                    size: Size(data.dates.length * _rowHeight, height),
                    painter: HeatmapPainter(
                      matrix: data,
                      emptyBorderColor: AppTokens.surfaceCardBorder,
                      emptyFillColor: AppTokens.surfaceCard,
                      labelColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      selectedColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onTap(Offset position, HeatmapMatrix data) {
    final col = position.dx ~/ _rowHeight;
    if (col < 0 || col >= data.dates.length) return;
    ref.read(selectedDateProvider.notifier).select(data.dates[col]);
  }
}

class HeatmapPainter extends CustomPainter {
  HeatmapPainter({
    required this.matrix,
    required this.emptyBorderColor,
    required this.labelColor,
    required this.selectedColor,
    this.emptyFillColor,
  });

  final HeatmapMatrix matrix;
  final Color emptyBorderColor;
  final Color? emptyFillColor;
  final Color labelColor;
  final Color selectedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint();
    final emptyStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = emptyBorderColor;

    // Day-of-month labels every other column; '1' marks a new month.
    // The rightmost column is the selected date (window ends there).
    final selectedCol = matrix.dates.length - 1;
    for (var col = 0; col < matrix.dates.length; col++) {
      final day = matrix.dates[col].substring(8);
      final isMonthStart = day == '01';
      if (col % 2 != 0 && !isMonthStart && col != selectedCol) continue;
      final painter = TextPainter(
        text: TextSpan(
          text: isMonthStart ? '1·' : day,
          style: TextStyle(
            fontSize: 9,
            color: col == selectedCol ? selectedColor : labelColor,
            fontWeight: col == selectedCol || isMonthStart
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          col * _rowHeight + (_cellSize - painter.width) / 2,
          (_dateBandHeight - painter.height) / 2,
        ),
      );
    }

    for (var row = 0; row < matrix.metrics.length; row++) {
      final metric = matrix.metrics[row];
      final rule = matrix.rules[metric.id];
      final values = matrix.values[metric.id] ?? const {};
      for (var col = 0; col < matrix.dates.length; col++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            col * _rowHeight,
            _dateBandHeight + row * _rowHeight,
            _cellSize,
            _cellSize,
          ),
          const Radius.circular(5),
        );
        final value = values[matrix.dates[col]];
        final colorName = value == null ? null : rule?.colorFor(value);
        if (colorName == null) {
          // No data: translucent card fill + thin outline — clearly
          // distinct from the 'white' bucket (spec 5.3, CR1-B rule 2).
          if (emptyFillColor != null) {
            canvas.drawRRect(
              rect.deflate(1.5),
              Paint()..color = emptyFillColor!,
            );
          }
          canvas.drawRRect(rect.deflate(1.5), emptyStroke);
        } else {
          fill.color = HeatColors.of(colorName);
          canvas.drawRRect(rect, fill);
        }
      }
    }

    // Selected-day column outline.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          selectedCol * _rowHeight - 1.5,
          _dateBandHeight - 1.5,
          _cellSize + 3,
          matrix.metrics.length * _rowHeight - _cellGap + 3,
        ),
        const Radius.circular(7),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = selectedColor.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(HeatmapPainter oldDelegate) =>
      oldDelegate.matrix != matrix;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/heatmap/heat_colors.dart';
import '../../data/repositories/analysis_repository.dart';
import 'analysis_providers.dart';

const _cellSize = 26.0;
const _cellGap = 3.0;
const _rowHeight = _cellSize + _cellGap;

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
          height: 200, child: Center(child: CircularProgressIndicator())),
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
        final height = data.metrics.length * _rowHeight;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                      emptyBorderColor: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.4),
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
  HeatmapPainter({required this.matrix, required this.emptyBorderColor});

  final HeatmapMatrix matrix;
  final Color emptyBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint();
    final emptyStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = emptyBorderColor;

    for (var row = 0; row < matrix.metrics.length; row++) {
      final metric = matrix.metrics[row];
      final rule = matrix.rules[metric.id];
      final values = matrix.values[metric.id] ?? const {};
      for (var col = 0; col < matrix.dates.length; col++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            col * _rowHeight,
            row * _rowHeight,
            _cellSize,
            _cellSize,
          ),
          const Radius.circular(5),
        );
        final value = values[matrix.dates[col]];
        final colorName = value == null ? null : rule?.colorFor(value);
        if (colorName == null) {
          // No data: dashed-look outline, clearly distinct from 'white'
          // (spec 5.3).
          canvas.drawRRect(rect.deflate(1.5), emptyStroke);
        } else {
          fill.color = HeatColors.of(colorName);
          canvas.drawRRect(rect, fill);
        }
      }
    }
  }

  @override
  bool shouldRepaint(HeatmapPainter oldDelegate) =>
      oldDelegate.matrix != matrix;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/analysis_repository.dart';
import '../shared/calendar_row.dart';
import 'analysis_providers.dart';
import 'heatmap_widget.dart';

/// Analysis page (spec 6.3): calendar, heatmap, daily breakdown.
class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key, this.onMetricTap});

  /// Opens the metric detail / money page (wired in phase 4/5).
  final void Function(Metric metric)? onMetricTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(breakdownProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: ListView(
        children: [
          const CalendarRow(),
          HeatmapWidget(onMetricTap: onMetricTap),
          const Divider(height: 24),
          breakdown.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (items) => items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No entries for this day.'),
                  )
                : Column(
                    children: [
                      for (final item in items)
                        BreakdownTile(item: item, onMetricTap: onMetricTap),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class BreakdownTile extends StatelessWidget {
  const BreakdownTile({super.key, required this.item, this.onMetricTap});

  final BreakdownItem item;
  final void Function(Metric metric)? onMetricTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final header = InkWell(
      key: ValueKey('breakdown-${item.metric.key}'),
      onTap: () => onMetricTap?.call(item.metric),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text('${item.metric.title}: ',
                style: theme.textTheme.titleMedium),
            Expanded(
              child: Text(item.valueText, style: theme.textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );

    final hasDetail = item.detail?.trim().isNotEmpty ?? false;
    if (!hasDetail && item.subItems.isEmpty) return header;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        if (hasDetail)
          _ExpandableDetail(text: item.detail!),
        for (final sub in item.subItems)
          Padding(
            padding: EdgeInsets.only(left: 16.0 + sub.indent * 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${'>' * sub.indent} ${sub.title}',
                    style: theme.textTheme.bodyMedium),
                if (sub.detail?.trim().isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('>> ${sub.detail}',
                        style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// '> [text_value]' collapsible line under a breakdown header.
class _ExpandableDetail extends StatefulWidget {
  const _ExpandableDetail({required this.text});

  final String text;

  @override
  State<_ExpandableDetail> createState() => _ExpandableDetailState();
}

class _ExpandableDetailState extends State<_ExpandableDetail> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _open = !_open),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_open ? Icons.arrow_drop_down : Icons.arrow_right, size: 20),
            Expanded(
              child: Text(
                widget.text,
                maxLines: _open ? null : 1,
                overflow: _open ? null : TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

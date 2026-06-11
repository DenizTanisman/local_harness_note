import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../money/money_card_body.dart';
import '../home_providers.dart';
import 'composite_body.dart';
import 'input_bodies.dart';

/// One entry card on the home page (spec 6.2).
class MetricCard extends ConsumerWidget {
  const MetricCard({
    super.key,
    required this.metric,
    required this.dayEntries,
    required this.selectedOptions,
  });

  final Metric metric;
  final Map<int, Entry> dayEntries;
  final Map<int, Set<int>> selectedOptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unfilled = _isUnfilled(ref);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: unfilled
            ? BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.45))
            : BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () => _toggleStar(context, ref),
                  icon: Icon(
                    metric.isStarred ? Icons.star : Icons.star_border,
                    size: 20,
                    color: metric.isStarred
                        ? Colors.amber
                        : theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(metric.title, style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () => _confirmDelete(context, ref),
                  child: const Text('Del'),
                ),
              ],
            ),
            _body(),
          ],
        ),
      ),
    );
  }

  bool _isUnfilled(WidgetRef ref) {
    if (metric.inputType == 'money') {
      return !(ref
              .watch(hasTransactionsProvider(ref.watch(homeDateProvider)))
              .value ??
          false);
    }
    if (metric.inputType == 'composite') {
      final children = ref.watch(childrenProvider(metric.id)).value ?? [];
      return !children.any((c) => dayEntries.containsKey(c.id));
    }
    return !dayEntries.containsKey(metric.id);
  }

  Widget _body() {
    final entry = dayEntries[metric.id];
    switch (metric.inputType) {
      case 'int':
        return IntBody(metric: metric, entry: entry);
      case 'text':
        return TextBody(metric: metric, entry: entry);
      case 'int_text':
        return IntTextBody(metric: metric, entry: entry);
      case 'checkbox':
        return CheckboxBody(
          metric: metric,
          selectedOptionIds: selectedOptions[metric.id] ?? const {},
        );
      case 'composite':
        return CompositeBody(metric: metric, dayEntries: dayEntries);
      case 'money':
        return const MoneyCardBody();
      default:
        return Text('Unsupported input type: ${metric.inputType}');
    }
  }

  /// Star flow (spec 6.2): ask for a ≤2-word heatmap label on star;
  /// unstar drops the metric off the map without touching history.
  Future<void> _toggleStar(BuildContext context, WidgetRef ref) async {
    final tree = ref.read(treeRepositoryProvider);
    if (metric.isStarred) {
      await tree.unstar(metric.id);
      return;
    }
    final label = await showDialog<String>(
      context: context,
      builder: (context) => _StarLabelDialog(initial: metric.title),
    );
    if (label != null) {
      await tree.star(metric, label);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${metric.title}?'),
        content: const Text(
            'This deletes the metric and ALL of its history. '
            'This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(entryRepositoryProvider).deleteMetric(metric.id);
    }
  }
}

/// Owns its controller so the dialog's exit animation can finish safely.
class _StarLabelDialog extends StatefulWidget {
  const _StarLabelDialog({required this.initial});

  final String initial;

  @override
  State<_StarLabelDialog> createState() => _StarLabelDialogState();
}

class _StarLabelDialogState extends State<_StarLabelDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to heatmap'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'How should this appear in the heatmap? (max 2 words)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final words = _controller.text.trim().split(RegExp(r'\s+'));
            final label = words.take(2).join(' ');
            Navigator.pop(context, label.isEmpty ? null : label);
          },
          child: const Text('Star'),
        ),
      ],
    );
  }
}


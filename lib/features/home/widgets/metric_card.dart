import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/repositories/analysis_repository.dart' show formatAmount;
import '../../../theme/app_tokens.dart';
import '../../money/money_providers.dart';
import '../../money/money_reveal.dart';
import '../../shell/tab_index.dart';
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
                color: theme.colorScheme.outline.withValues(alpha: 0.45),
              )
            : BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Core metrics are fixed on the heatmap, so they show no star
                // toggle; only later, user-added metrics expose it.
                if (metric.isDeletable)
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
                  )
                else
                  const SizedBox(width: 4),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(metric.title, style: theme.textTheme.titleMedium),
                ),
                // Core metrics show NO Del at all — absence, not a disabled
                // button (CR-2).
                if (metric.isDeletable)
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTokens.danger,
                    ),
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
        // CR-3: money input lives in the dashboard's Quick money card and
        // the Money tab; here it's a read-only deep link, so there is only
        // ever one money form on screen.
        return const _MoneyDeepLink();
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
          'This cannot be undone.',
        ),
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
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

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

/// Read-only money row inside the Daily Check-in (CR-3): the money form
/// lives in the dashboard and the Money tab, so this only deep-links.
class _MoneyDeepLink extends ConsumerWidget {
  const _MoneyDeepLink();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(homeDateProvider);
    final total = ref.watch(dayOutcomeProvider(date)).value ?? 0;
    return InkWell(
      onTap: () => ref.read(tabIndexProvider.notifier).goTo(AppTab.money),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text('Spent today', style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            MoneyText(
              id: 'money-main-spent',
              amount: '${formatAmount(total)} ₺',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

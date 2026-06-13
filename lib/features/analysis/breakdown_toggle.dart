import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/analysis_repository.dart';
import '../money/money_reveal.dart';

bool _isMoneyNode(BreakdownNode node) =>
    node.id == 'money' || node.id.startsWith('money/');

bool _moneyMasked(BreakdownNode node, MoneyReveal reveal) =>
    _isMoneyNode(node) && !reveal.shows(node.id);

/// Hide the amount (everything after the last ': ') on a masked money node.
String _displayTitle(BreakdownNode node, MoneyReveal reveal) {
  if (!_moneyMasked(node, reveal)) return node.title;
  final i = node.title.lastIndexOf(': ');
  return i < 0 ? node.title : '${node.title.substring(0, i)}: $moneyMask';
}

/// Session-scoped expansion state for the breakdown tree (CR1-A).
/// Not persisted; survives rebuilds and date changes within the session.
class BreakdownExpansionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) {
    state = state.contains(id) ? (Set.of(state)..remove(id)) : {...state, id};
  }
}

final breakdownExpansionProvider =
    NotifierProvider<BreakdownExpansionNotifier, Set<String>>(
      BreakdownExpansionNotifier.new,
    );

/// Root row of the breakdown: always visible, no arrow; its level-1
/// children render as collapsed [ToggleRow]s (CR1-A).
class BreakdownRootTile extends ConsumerWidget {
  const BreakdownRootTile({super.key, required this.node, this.onMetricTap});

  final BreakdownNode node;
  final void Function(Metric metric)? onMetricTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reveal = ref.watch(moneyRevealProvider);
    final masked = _moneyMasked(node, reveal);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: ValueKey('breakdown-${node.id}'),
          onTap: masked
              ? () => revealMoneyFlow(context, ref, node.id)
              : (node.metric == null
                    ? null
                    : () => onMetricTap?.call(node.metric!)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _displayTitle(node, reveal),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        for (final child in node.children)
          ToggleRow(node: child, depth: 1, onMetricTap: onMetricTap),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// One collapsible row: 32dp arrow target toggles; the TITLE opens the
/// metric page (two distinct tap targets, CR1-A).
class ToggleRow extends ConsumerWidget {
  const ToggleRow({
    super.key,
    required this.node,
    required this.depth,
    this.onMetricTap,
  });

  final BreakdownNode node;
  final int depth;
  final void Function(Metric metric)? onMetricTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(breakdownExpansionProvider).contains(node.id);
    final reveal = ref.watch(moneyRevealProvider);
    final masked = _moneyMasked(node, reveal);
    final theme = Theme.of(context);

    void toggle() =>
        ref.read(breakdownExpansionProvider.notifier).toggle(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0 * depth),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: node.hasArrow
                    ? InkWell(
                        key: ValueKey('toggle-${node.id}'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: toggle,
                        child: Icon(
                          expanded ? Icons.arrow_drop_down : Icons.arrow_right,
                          size: 22,
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: InkWell(
                  key: ValueKey('title-${node.id}'),
                  onTap: masked
                      ? () => revealMoneyFlow(context, ref, node.id)
                      : (node.metric != null
                            ? () => onMetricTap?.call(node.metric!)
                            : (node.hasArrow ? toggle : null)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      _displayTitle(node, reveal),
                      maxLines: node.inlineExpand && !expanded ? 1 : null,
                      overflow: node.inlineExpand && !expanded
                          ? TextOverflow.ellipsis
                          : null,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (expanded)
          for (final child in node.children)
            ToggleRow(node: child, depth: depth + 1, onMetricTap: onMetricTap),
      ],
    );
  }
}

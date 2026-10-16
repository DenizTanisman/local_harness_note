import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../home_providers.dart';

/// Long-press drag wrapper for a top-level card (spec §7).
class DraggableMetricCard extends ConsumerWidget {
  const DraggableMetricCard({
    super.key,
    required this.metric,
    required this.child,
  });

  final Metric metric;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LongPressDraggable<Metric>(
      data: metric,
      onDragStarted: () => ref.read(draggingProvider.notifier).set(true),
      onDragEnd: (_) => ref.read(draggingProvider.notifier).set(false),
      onDraggableCanceled: (_, _) =>
          ref.read(draggingProvider.notifier).set(false),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 24,
          child: Transform.scale(scale: 1.03, child: child),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: DropOntoCardTarget(metric: metric, child: child),
    );
  }
}

/// Dropping a card ONTO another card makes it a child of the target
/// after confirmation; the target is promoted to composite if needed.
class DropOntoCardTarget extends ConsumerWidget {
  const DropOntoCardTarget({
    super.key,
    required this.metric,
    required this.child,
  });

  final Metric metric;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Metric>(
      onWillAcceptWithDetails: (details) => details.data.id != metric.id,
      onAcceptWithDetails: (details) async {
        final dragged = details.data;
        final tree = ref.read(treeRepositoryProvider);
        final messenger = ScaffoldMessenger.of(context);
        if (!await tree.canBecomeChildOf(dragged, metric)) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                dragged.inputType == 'composite'
                    ? 'Groups cannot be nested (max 2 levels).'
                    : 'This card cannot be grouped here.',
              ),
            ),
          );
          return;
        }
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Make ${dragged.title} a sub-item of ${metric.title}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Group'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await tree.makeChildOf(childId: dragged.id, parentId: metric.id);
        }
      },
      builder: (context, candidates, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: candidates.isNotEmpty
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// Gap between cards: drop here to reorder, or to pull a child out of its
/// group (spec §7 — drag to empty space/root detaches).
class GapDropTarget extends ConsumerWidget {
  const GapDropTarget({super.key, required this.index});

  /// Insertion index among top-level cards.
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dragging = ref.watch(draggingProvider);
    return DragTarget<Metric>(
      onAcceptWithDetails: (details) => ref
          .read(treeRepositoryProvider)
          .moveToRootPosition(details.data.id, index),
      builder: (context, candidates, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: dragging ? (candidates.isNotEmpty ? 36 : 18) : 6,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: candidates.isNotEmpty
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)
              : null,
        ),
      ),
    );
  }
}

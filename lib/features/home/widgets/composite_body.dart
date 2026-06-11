import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../home_providers.dart';
import 'input_bodies.dart';

/// Composite group body ('composite'), e.g. Development: pick the sub-areas
/// worked on today, then describe each (spec 4.2).
class CompositeBody extends ConsumerWidget {
  const CompositeBody({
    super.key,
    required this.metric,
    required this.dayEntries,
  });

  final Metric metric;
  final Map<int, Entry> dayEntries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider(metric.id));
    return children.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
      data: (rows) {
        if (rows.isEmpty) {
          return Text(
            'No sub-items yet — drop a card onto this one to group it.',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final child in rows)
                  // Long-press drag a chip into a list gap to pull the
                  // sub-item out of the group (spec §7).
                  LongPressDraggable<Metric>(
                    data: child,
                    onDragStarted: () =>
                        ref.read(draggingProvider.notifier).set(true),
                    onDragEnd: (_) =>
                        ref.read(draggingProvider.notifier).set(false),
                    feedback: Material(
                      color: Colors.transparent,
                      child: Chip(label: Text(child.title)),
                    ),
                    child: FilterChip(
                      label: Text(child.title),
                      selected: dayEntries.containsKey(child.id),
                      onSelected: (selected) {
                        final repo = ref.read(entryRepositoryProvider);
                        final date = ref.read(homeDateProvider);
                        if (selected) {
                          repo.saveEntry(metricId: child.id, date: date);
                        } else {
                          repo.clearEntry(child.id, date);
                        }
                      },
                    ),
                  ),
              ],
            ),
            for (final child in rows)
              if (dayEntries.containsKey(child.id))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextBody(
                    key: ValueKey('composite-text-${child.id}'),
                    metric: child,
                    entry: dayEntries[child.id],
                    hint: child.title,
                  ),
                ),
          ],
        );
      },
    );
  }
}

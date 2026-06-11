import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_providers.dart';
import 'widgets/add_metric_sheet.dart';
import 'widgets/metric_card.dart';

/// Home (entry) page — spec 6.2.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(homeDateProvider);
    final metrics = ref.watch(topLevelMetricsProvider);
    final entries = ref.watch(entriesForDateProvider(date));
    final options = ref.watch(selectedOptionsProvider(date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(date, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
      drawer: const Drawer(
        // Settings / Export entries arrive in phase 7.
        child: SafeArea(child: Center(child: Text('Daily Tracker'))),
      ),
      body: metrics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rows) => ListView(
          padding: const EdgeInsets.only(top: 6, bottom: 24),
          children: [
            for (final metric in rows)
              MetricCard(
                key: ValueKey('metric-card-${metric.id}'),
                metric: metric,
                dayEntries: entries.value ?? const {},
                selectedOptions: options.value ?? const {},
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: OutlinedButton.icon(
                onPressed: () => AddMetricSheet.show(context),
                icon: const Icon(Icons.add),
                label: const Text('ADD'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

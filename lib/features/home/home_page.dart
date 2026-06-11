import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/export_import_page.dart';
import '../settings/settings_page.dart';
import 'home_providers.dart';
import 'widgets/add_metric_sheet.dart';
import 'widgets/drag_targets.dart';
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
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(child: Text('Daily Tracker')),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const SettingsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Export / Import'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ExportImportPage()));
                },
              ),
            ],
          ),
        ),
      ),
      body: metrics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rows) => rows.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No metrics yet.'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => AddMetricSheet.show(context),
                      icon: const Icon(Icons.add),
                      label: const Text('ADD'),
                    ),
                  ],
                ),
              )
            : ListView(
          padding: const EdgeInsets.only(top: 6, bottom: 24),
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              GapDropTarget(index: i),
              DraggableMetricCard(
                key: ValueKey('metric-card-${rows[i].id}'),
                metric: rows[i],
                child: MetricCard(
                  metric: rows[i],
                  dayEntries: entries.value ?? const {},
                  selectedOptions: options.value ?? const {},
                ),
              ),
            ],
            GapDropTarget(index: rows.length),
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

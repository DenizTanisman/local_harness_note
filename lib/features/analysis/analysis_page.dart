import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../theme/glow_background.dart';
import '../shared/calendar_row.dart';
import 'analysis_providers.dart';
import 'breakdown_toggle.dart';
import 'heatmap_widget.dart';
import '../settings/settings_button.dart';

/// Analysis page (spec 6.3): calendar, heatmap, daily breakdown.
class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key, this.onMetricTap});

  /// Opens the metric detail page.
  final void Function(Metric metric)? onMetricTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(breakdownProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
        actions: const [SettingsButton()],
      ),
      body: GlowBackground(
        child: ListView(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final node in items)
                          BreakdownRootTile(
                            node: node,
                            onMetricTap: onMetricTap,
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

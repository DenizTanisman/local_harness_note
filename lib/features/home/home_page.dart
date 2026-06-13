import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../theme/glow_background.dart';
import '../settings/export_import_page.dart';
import '../settings/settings_page.dart';
import 'home_providers.dart';
import 'widgets/add_metric_sheet.dart';
import 'widgets/dashboard.dart';
import 'widgets/drag_targets.dart';
import 'widgets/metric_card.dart';

/// Main tab (CR-3 §3): dashboard (quick money, today summary, balance)
/// above the Daily Check-in (the spec §6.2 metric cards).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(homeDateProvider);
    final isToday = date == dateKey(DateTime.now());
    final metrics = ref.watch(topLevelMetricsProvider);
    final entries = ref.watch(entriesForDateProvider(date));
    final options = ref.watch(selectedOptionsProvider(date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
        actions: [
          // Past-day entry mode (CR1-D): tap the chip to pick a past day;
          // a visible 'Today' escape appears whenever not on today.
          if (!isToday)
            TextButton(
              key: const ValueKey('today-button'),
              onPressed: () =>
                  ref.read(homeDateProvider.notifier).resetToToday(),
              child: const Text('Today'),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _DateChip(date: date, highlighted: !isToday),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Export / Import'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExportImportPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: GlowBackground(
        child: metrics.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (rows) => ListView(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            children: [
              // Dashboard (CR-3 §3) — order: quick money → today → balance.
              const QuickMoneyCard(),
              const TodaySummaryCard(),
              const BalanceCard(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Daily Check-in'),
              ),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
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
              else ...[
                for (var i = 0; i < rows.length; i++) ...[
                  GapDropTarget(index: i),
                  DraggableMetricCard(
                    // Keyed by date too: input controllers must re-seed
                    // when the active write date changes (CR1-D).
                    key: ValueKey('metric-card-${rows[i].id}-$date'),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable date chip in the app bar (CR1-D). Highlighted whenever the
/// active write date is not today — writing to the past must be obvious.
class _DateChip extends ConsumerWidget {
  const _DateChip({required this.date, required this.highlighted});

  final String date;
  final bool highlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      key: const ValueKey('home-date-chip'),
      borderRadius: BorderRadius.circular(999),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: parseDateKey(date),
          firstDate: DateTime(2020),
          lastDate: now, // the future stays blocked
        );
        if (picked != null) {
          ref.read(homeDateProvider.notifier).select(dateKey(picked));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: highlighted ? scheme.primary : Colors.transparent,
          border: Border.all(
            color: highlighted ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Text(
          date,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: highlighted ? scheme.onPrimary : null,
            fontWeight: highlighted ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }
}

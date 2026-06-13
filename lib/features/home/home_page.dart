import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../../theme/glow_background.dart';
import '../settings/settings_button.dart';
import '../shared/period_bar.dart';
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
        actions: const [SettingsButton()],
      ),
      body: GlowBackground(
        child: metrics.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (rows) => ListView(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            children: [
              // Unified write-date selector (CR-3 follow-up #5 + CR1-D):
              // any past day; highlighted + 'Today' reset when not today.
              PeriodBar(
                label: date,
                highlighted: !isToday,
                canGoNext: !isToday,
                resetLabel: 'Today',
                onReset: () =>
                    ref.read(homeDateProvider.notifier).resetToToday(),
                onPrev: () => ref
                    .read(homeDateProvider.notifier)
                    .select(
                      dateKey(
                        parseDateKey(date).subtract(const Duration(days: 1)),
                      ),
                    ),
                onNext: () => ref
                    .read(homeDateProvider.notifier)
                    .select(
                      dateKey(parseDateKey(date).add(const Duration(days: 1))),
                    ),
                onTapLabel: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: parseDateKey(date),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    ref.read(homeDateProvider.notifier).select(dateKey(picked));
                  }
                },
              ),
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

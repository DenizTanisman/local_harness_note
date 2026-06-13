import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/analysis_repository.dart' show formatAmount;
import '../../../data/repositories/screen_time_repository.dart'
    show formatMinutes;
import '../../money/money_card_body.dart';
import '../../money/money_providers.dart';
import '../../money/money_reveal.dart';
import '../../screentime/screentime_providers.dart';
import '../../shell/tab_index.dart';
import '../home_providers.dart';

/// Quick money entry on Main (CR-3 §3) — the same form as the Money tab,
/// writing to `transactions` at the active write date (CR1-D).
class QuickMoneyCard extends ConsumerWidget {
  const QuickMoneyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(homeDateProvider);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quick money', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            // Re-key on date change so an open form resets and never writes
            // to the wrong day (matches the CR1-D card behavior).
            MoneyCardBody(key: ValueKey('quick-money-$date')),
          ],
        ),
      ),
    );
  }
}

/// Today's sensor/calorie summary (CR-3 §3). Values are placeholders until
/// CR3-P3/P6 populate them; each row deep-links to its tab.
class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void goTo(int tab) => ref.read(tabIndexProvider.notifier).goTo(tab);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Align(alignment: Alignment.centerLeft, child: Text('Today')),
          ),
          _SummaryRow(
            icon: Icons.local_fire_department_outlined,
            label: 'Calories',
            value: '—',
            onTap: () => goTo(AppTab.sport),
          ),
          _SummaryRow(
            icon: Icons.directions_walk,
            label: 'Steps',
            value: '—',
            onTap: () => goTo(AppTab.health),
          ),
          _SummaryRow(
            icon: Icons.favorite_outline,
            label: 'Resting HR',
            value: '—',
            onTap: () => goTo(AppTab.health),
          ),
          _SummaryRow(
            icon: Icons.bedtime_outlined,
            label: 'Sleep',
            value: '—',
            onTap: () => goTo(AppTab.health),
          ),
          // Screen time (CR-4 §3.2): glanceable total → Health.
          Consumer(
            builder: (context, ref, _) {
              final st = ref.watch(todayScreenTimeProvider).value;
              final value = st == null || st.isEmpty
                  ? '—'
                  : '${formatMinutes(st.totalMinutes)} (~)';
              return _SummaryRow(
                icon: Icons.phone_android,
                label: 'Screen time',
                value: value,
                onTap: () => goTo(AppTab.health),
              );
            },
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(label),
      trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      onTap: onTap,
    );
  }
}

/// This month's net balance (CR-3 §3), derived from transactions; taps to
/// the Money tab.
class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(homeDateProvider).substring(0, 7);
    final general = ref.watch(moneyGeneralByMonthProvider(month));
    final balance = general.maybeWhen(data: monthBalance, orElse: () => null);
    final style = Theme.of(context).textTheme.titleMedium;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet_outlined),
        title: const Text('This month'),
        trailing: balance == null
            ? Text('—', style: style)
            : MoneyText(
                id: 'money-main-balance',
                amount:
                    '${balance >= 0 ? '+' : '−'}${formatAmount(balance.abs())} ₺',
                style: style,
              ),
        onTap: () => ref.read(tabIndexProvider.notifier).goTo(AppTab.money),
      ),
    );
  }
}

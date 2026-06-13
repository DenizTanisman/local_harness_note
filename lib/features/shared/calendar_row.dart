import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../analysis/analysis_providers.dart';
import 'period_bar.dart';

/// Day selector for Analysis + Detail (spec 6.3/6.4) — now the unified
/// [PeriodBar] bound to the Analysis selected date (CR-3 follow-up #5).
class CalendarRow extends ConsumerWidget {
  const CalendarRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final notifier = ref.read(selectedDateProvider.notifier);
    final today = dateKey(DateTime.now());
    final day = parseDateKey(date);

    return PeriodBar(
      label: date,
      highlighted: date != today,
      canGoNext: date.compareTo(today) < 0,
      resetLabel: 'Today',
      onReset: () => notifier.select(today),
      onPrev: () =>
          notifier.select(dateKey(day.subtract(const Duration(days: 1)))),
      onNext: () => notifier.select(dateKey(day.add(const Duration(days: 1)))),
      onTapLabel: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: day,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(), // future not selectable
        );
        if (picked != null) notifier.select(dateKey(picked));
      },
    );
  }
}

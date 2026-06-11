import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_key.dart';
import '../analysis/analysis_providers.dart';

/// Shared calendar row (spec 6.3/6.4): shows the selected date; tap opens a
/// picker capped at today. Used by analysis, detail and money pages.
class CalendarRow extends ConsumerWidget {
  const CalendarRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    return InkWell(
      key: const ValueKey('calendar-row'),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: parseDateKey(date),
          firstDate: DateTime(2020),
          lastDate: now, // future dates not selectable
        );
        if (picked != null) {
          ref.read(selectedDateProvider.notifier).select(dateKey(picked));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 20),
            const SizedBox(width: 8),
            Text(date, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

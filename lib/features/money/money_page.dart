import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/secure_window.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/analysis_repository.dart' show formatAmount;
import '../../data/repositories/money_repository.dart';
import '../analysis/analysis_providers.dart';
import '../settings/settings_providers.dart';
import '../shared/calendar_row.dart';
import 'money_providers.dart';

/// Money page (spec 6.5): calendar + General / Monthly switch.
class MoneyPage extends ConsumerStatefulWidget {
  const MoneyPage({super.key});

  @override
  ConsumerState<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends ConsumerState<MoneyPage> {
  bool _monthly = false;
  bool _secured = false;

  @override
  void initState() {
    super.initState();
    // FLAG_SECURE only while a Money page is open (spec §11.6, default off).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings =
          await ref.read(settingsRepositoryProvider).loadAll();
      if (mounted && settings['flag_secure'] == 'true') {
        _secured = true;
        await SecureWindow.enable();
      }
    });
  }

  @override
  void dispose() {
    if (_secured) SecureWindow.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money')),
      body: ListView(
        children: [
          const CalendarRow(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('General')),
                ButtonSegment(value: true, label: Text('Monthly')),
              ],
              selected: {_monthly},
              onSelectionChanged: (selection) =>
                  setState(() => _monthly = selection.first),
            ),
          ),
          const SizedBox(height: 12),
          if (_monthly) const _MonthlyView() else const _GeneralView(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- General

class _GeneralView extends ConsumerWidget {
  const _GeneralView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final general = ref.watch(moneyGeneralProvider);
    final date = ref.watch(selectedDateProvider);
    return general.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (data) {
        final incomeTotal =
            data.income.fold<double>(0, (acc, c) => acc + c.total);
        final outcomeTotal =
            data.outcome.fold<double>(0, (acc, c) => acc + c.total);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _MoneySparkline(
                general: data,
                month: date.substring(0, 7),
                selectedDay: int.parse(date.substring(8)),
                onDayTap: (day) {
                  ref.read(selectedDateProvider.notifier).select(
                      '${date.substring(0, 7)}-${day.toString().padLeft(2, '0')}');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Daily budget: ${formatAmount(data.dailyBudget)} TL '
                '(red dot = luxury above budget)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            _CategoryBlock(
              key: const ValueKey('income-block'),
              title: 'Income: ${formatAmount(incomeTotal)}',
              categories: data.income,
            ),
            _CategoryBlock(
              key: const ValueKey('outcome-block'),
              title: 'Outcome: ${formatAmount(outcomeTotal)}',
              categories: data.outcome,
            ),
          ],
        );
      },
    );
  }
}

/// 'Income: 15.000' header with '> Scholarship: 15.000' children and
/// '>> Bill (home): 2.000' subtype breakdown (spec 6.5).
class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({super.key, required this.title, required this.categories});

  final String title;
  final List<CategoryTotal> categories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      title: Text(title, style: theme.textTheme.titleMedium),
      initiallyExpanded: true,
      childrenPadding: const EdgeInsets.only(left: 32, bottom: 8, right: 16),
      children: [
        for (final category in categories) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '> ${category.name}: ${formatAmount(category.total)}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          for (final sub in category.subtypes)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '>> ${sub.label}: ${formatAmount(sub.total)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Red/green daily-luxury sparkline (spec 6.5).
class _MoneySparkline extends StatelessWidget {
  const _MoneySparkline({
    required this.general,
    required this.month,
    required this.selectedDay,
    this.onDayTap,
  });

  final MoneyGeneral general;
  final String month;
  final int selectedDay;
  final void Function(int day)? onDayTap;

  int get _daysInMonth {
    final parts = month.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1] + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth;
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        key: const ValueKey('money-sparkline'),
        onTapUp: (details) {
          final step = constraints.maxWidth / (days - 1);
          final day = (details.localPosition.dx / step).round() + 1;
          if (day >= 1 && day <= days) onDayTap?.call(day);
        },
        child: CustomPaint(
          size: Size(constraints.maxWidth, 160),
          painter: _MoneySparklinePainter(
            general: general,
            days: days,
            selectedDay: selectedDay,
            gridColor:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

class _MoneySparklinePainter extends CustomPainter {
  _MoneySparklinePainter({
    required this.general,
    required this.days,
    required this.selectedDay,
    required this.gridColor,
  });

  final MoneyGeneral general;
  final int days;
  final int selectedDay;
  final Color gridColor;

  static const _red = Color(0xFFDA3633);
  static const _green = Color(0xFF2EA043);

  @override
  void paint(Canvas canvas, Size size) {
    final step = size.width / (days - 1);
    final values = general.days;
    final maxValue = values.values.isEmpty
        ? 1.0
        : values.values
            .map((p) => p.luxury)
            .reduce((a, b) => a > b ? a : b);
    final scale = maxValue == 0 ? 1.0 : maxValue;

    Offset pointFor(int day, double value) => Offset(
          (day - 1) * step,
          size.height - 12 - (value / scale) * (size.height - 24),
        );

    canvas.drawLine(
      Offset(0, size.height - 12),
      Offset(size.width, size.height - 12),
      Paint()
        ..color = gridColor
        ..strokeWidth = 1,
    );

    // Budget line.
    if (general.dailyBudget > 0 && general.dailyBudget <= scale) {
      final y = pointFor(1, general.dailyBudget).dy;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
    }

    final line = Paint()
      ..color = gridColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final sortedDays = values.keys.toList()..sort();
    final baseY = size.height - 12;
    final segments = <List<Offset>>[];
    int? prev;
    for (final day in sortedDays) {
      final point = pointFor(day, values[day]!.luxury);
      if (prev == null || day != prev + 1) {
        segments.add([point]);
      } else {
        segments.last.add(point);
      }
      prev = day;
    }
    for (final segment in segments) {
      final path = Path()..moveTo(segment.first.dx, segment.first.dy);
      for (final point in segment.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      if (segment.length > 1) {
        final area = Path.from(path)
          ..lineTo(segment.last.dx, baseY)
          ..lineTo(segment.first.dx, baseY)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _green.withValues(alpha: 0.18),
                _green.withValues(alpha: 0.02),
              ],
            ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
        );
      }
      canvas.drawPath(path, line);
    }

    for (final day in sortedDays) {
      final dayPoint = values[day]!;
      final point = pointFor(day, dayPoint.luxury);
      final color = dayPoint.overBudget ? _red : _green;
      if (day == selectedDay) {
        canvas.drawCircle(
            point,
            8,
            Paint()
              ..color = color.withValues(alpha: 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      }
      canvas.drawCircle(
        point,
        day == selectedDay ? 5 : 3.5,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_MoneySparklinePainter oldDelegate) =>
      oldDelegate.general != general ||
      oldDelegate.selectedDay != selectedDay;
}

// ---------------------------------------------------------------- Monthly

class _MonthlyView extends ConsumerWidget {
  const _MonthlyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final table = ref.watch(monthlyTableProvider);
    final theme = Theme.of(context);
    return table.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (rows) {
        if (rows.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No transactions this month.'),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Income', style: theme.textTheme.labelLarge)),
                  SizedBox(
                      width: 56,
                      child: Center(
                          child:
                              Text('Date', style: theme.textTheme.labelLarge))),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child:
                          Text('Outcome', style: theme.textTheme.labelLarge),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            for (final row in rows) _MonthlyRowTile(row: row),
          ],
        );
      },
    );
  }
}

class _MonthlyRowTile extends ConsumerWidget {
  const _MonthlyRowTile({required this.row});

  final MonthlyTableRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Widget cell(Transaction? tx, {required bool alignEnd}) {
      if (tx == null) return const Expanded(child: SizedBox.shrink());
      return Expanded(
        child: InkWell(
          onLongPress: () => _editOrDelete(context, ref, tx),
          child: Column(
            crossAxisAlignment:
                alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(displayCategory(tx), style: theme.textTheme.bodyMedium),
              Text(formatAmount(tx.amount), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cell(row.income, alignEnd: false),
          SizedBox(
            width: 56,
            child: Center(
              child: Text(row.date.substring(8),
                  style: theme.textTheme.bodyMedium),
            ),
          ),
          cell(row.outcome, alignEnd: true),
        ],
      ),
    );
  }

  Future<void> _editOrDelete(
      BuildContext context, WidgetRef ref, Transaction tx) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('Edit ${displayCategory(tx)}'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'delete') {
      await ref.read(moneyRepositoryProvider).deleteTransaction(tx.id);
    } else if (action == 'edit' && context.mounted) {
      final updated = await showDialog<({double amount, String subtype})>(
        context: context,
        builder: (context) => _EditTransactionDialog(tx: tx),
      );
      if (updated != null) {
        await ref.read(moneyRepositoryProvider).updateTransaction(
              tx.id,
              amount: updated.amount,
              category: tx.category,
              subtype: updated.subtype,
              note: tx.note,
            );
      }
    }
  }
}

class _EditTransactionDialog extends StatefulWidget {
  const _EditTransactionDialog({required this.tx});

  final Transaction tx;

  @override
  State<_EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  late final TextEditingController _amount =
      TextEditingController(text: widget.tx.amount.toString());
  late final TextEditingController _subtype =
      TextEditingController(text: widget.tx.subtype ?? '');

  @override
  void dispose() {
    _amount.dispose();
    _subtype.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.tx.category}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          TextField(
            controller: _subtype,
            decoration: const InputDecoration(labelText: 'Subtype (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount =
                double.tryParse(_amount.text.replaceAll(',', '.'));
            if (amount == null || amount < 0) return;
            Navigator.pop(context, (amount: amount, subtype: _subtype.text));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

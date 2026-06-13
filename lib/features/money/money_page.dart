import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/secure_window.dart';
import '../../data/db/app_database.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/analysis_repository.dart' show formatAmount;
import '../../data/repositories/money_repository.dart';
import '../../theme/app_tokens.dart';
import '../../theme/glow_background.dart';
import '../home/home_providers.dart';
import '../settings/settings_providers.dart';
import '../shared/continuous_sparkline.dart';
import 'category_donut.dart';
import 'money_card_body.dart';
import 'money_providers.dart';

/// Money tab (CR-3 §4): shared entry form on top, then a tap-only inner
/// nav (Overview / Transactions / Categories). Global swipe stays free.
class MoneyPage extends ConsumerStatefulWidget {
  const MoneyPage({super.key});

  @override
  ConsumerState<MoneyPage> createState() => _MoneyPageState();
}

enum _MoneyView { overview, transactions, categories }

class _MoneyPageState extends ConsumerState<MoneyPage> {
  _MoneyView _view = _MoneyView.overview;
  bool _secured = false;

  @override
  void initState() {
    super.initState();
    // FLAG_SECURE only while a Money page is open (spec §11.6, default off).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = await ref.read(settingsRepositoryProvider).loadAll();
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
    final month = ref.watch(moneyMonthProvider);
    final date = ref.watch(homeDateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Money')),
      body: GlowBackground(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Shared entry form (writes at the active date, with the
            // outcome reminder flow — spec §6.2).
            Card(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: MoneyCardBody(key: ValueKey('money-tab-form-$date')),
              ),
            ),
            // Month selector for the views below.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () =>
                        ref.read(moneyMonthProvider.notifier).shift(-1),
                  ),
                  Text(month, style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () =>
                        ref.read(moneyMonthProvider.notifier).shift(1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<_MoneyView>(
                segments: const [
                  ButtonSegment(
                    value: _MoneyView.overview,
                    label: Text('Overview'),
                  ),
                  ButtonSegment(
                    value: _MoneyView.transactions,
                    label: Text('Transactions'),
                  ),
                  ButtonSegment(
                    value: _MoneyView.categories,
                    label: Text('Categories'),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (s) => setState(() => _view = s.first),
              ),
            ),
            const SizedBox(height: 8),
            switch (_view) {
              _MoneyView.overview => const _OverviewSection(),
              _MoneyView.transactions => const _TransactionsSection(),
              _MoneyView.categories => const _CategoriesSection(),
            },
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- Overview

class _OverviewSection extends ConsumerWidget {
  const _OverviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(moneyMonthProvider);
    final general = ref.watch(moneyGeneralByMonthProvider(month));
    return general.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
      data: (data) {
        final balance = monthBalance(data);
        final incomeTotal = data.income.fold<double>(0, (a, c) => a + c.total);
        final outcomeTotal = data.outcome.fold<double>(
          0,
          (a, c) => a + c.total,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Balance: ${balance >= 0 ? '+' : '−'}'
                '${formatAmount(balance.abs())} ₺',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Red/green daily-budget sparkline (spec §6.5 General, kept as
            // an Overview sub-view per CR-3 §4).
            Builder(
              builder: (context) {
                final parts = month.split('-').map(int.parse).toList();
                final days = DateTime(parts[0], parts[1] + 1, 0).day;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: KeyedSubtree(
                    key: const ValueKey('money-sparkline'),
                    child: ContinuousSparkline(
                      daysInMonth: days,
                      values: {
                        for (final e in data.days.entries)
                          e.key: e.value.luxury,
                      },
                      dayColors: moneyDayColors(days, data),
                      lineColor: AppTokens.moneyGreen,
                      selectedDay: 1,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'Daily budget: ${formatAmount(data.dailyBudget)} ₺ '
                '(red = luxury above budget)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            CategoryDonut(categories: data.outcome),
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

/// Collapsible Income/Outcome breakdown (CR1-A style): category total with
/// a 'Bill (home)' subtype breakdown underneath.
class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({
    super.key,
    required this.title,
    required this.categories,
  });

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

// ------------------------------------------------------------- Transactions

class _TransactionsSection extends ConsumerWidget {
  const _TransactionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(moneyTabTransactionsProvider);
    return txs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
      data: (rows) {
        if (rows.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No transactions this month.'),
          );
        }
        return Column(
          children: [for (final tx in rows) _TransactionTile(tx: tx)],
        );
      },
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({required this.tx});

  final Transaction tx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = tx.direction == 'income';
    final color = income ? AppTokens.moneyGreen : AppTokens.danger;
    return ListTile(
      leading: Icon(income ? Icons.south_west : Icons.north_east, color: color),
      title: Text(displayCategory(tx)),
      subtitle: Text(tx.date),
      trailing: Text(
        '${income ? '+' : '−'}${formatAmount(tx.amount)} ₺',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
      onLongPress: () => _editOrDelete(context, ref),
    );
  }

  Future<void> _editOrDelete(BuildContext context, WidgetRef ref) async {
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
        await ref
            .read(moneyRepositoryProvider)
            .updateTransaction(
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
  late final TextEditingController _amount = TextEditingController(
    text: widget.tx.amount.toString(),
  );
  late final TextEditingController _subtype = TextEditingController(
    text: widget.tx.subtype ?? '',
  );

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
            final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
            if (amount == null || amount < 0) return;
            Navigator.pop(context, (amount: amount, subtype: _subtype.text));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- Categories

class _CategoriesSection extends ConsumerWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allMoneyCategoriesProvider);
    final db = ref.watch(databaseProvider);
    return categories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
      data: (rows) {
        Widget section(String direction, String label) {
          final items = rows.where((c) => c.direction == direction).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Expanded(child: Text(label)),
                    TextButton.icon(
                      onPressed: () => _addCategory(context, ref, direction),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
              for (final c in items)
                ListTile(
                  title: Text(c.name),
                  subtitle: direction == 'outcome'
                      ? Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('Essential'),
                              selected: c.isEssential,
                              onSelected: (v) =>
                                  (db.update(
                                    db.moneyCategories,
                                  )..where((m) => m.id.equals(c.id))).write(
                                    MoneyCategoriesCompanion(
                                      isEssential: Value(v),
                                    ),
                                  ),
                            ),
                            FilterChip(
                              label: const Text('In heatmap'),
                              selected: c.countsInHeatmap,
                              onSelected: (v) =>
                                  (db.update(
                                    db.moneyCategories,
                                  )..where((m) => m.id.equals(c.id))).write(
                                    MoneyCategoriesCompanion(
                                      countsInHeatmap: Value(v),
                                    ),
                                  ),
                            ),
                          ],
                        )
                      : null,
                ),
            ],
          );
        }

        return Column(
          children: [
            section('outcome', 'Outcome categories'),
            const Divider(),
            section('income', 'Income categories'),
          ],
        );
      },
    );
  }

  Future<void> _addCategory(
    BuildContext context,
    WidgetRef ref,
    String direction,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _NewCategoryDialog(),
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(moneyRepositoryProvider).addCategory(direction, name);
    }
  }
}

class _NewCategoryDialog extends StatefulWidget {
  const _NewCategoryDialog();

  @override
  State<_NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<_NewCategoryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New category'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// Per-day line colors for the Money budget sparkline (spec §6.5): red when
/// the day's luxury spend exceeds the daily budget, green otherwise.
/// Index 0 unused; 1..N are days. Used by the Overview chart and tests.
List<Color> moneyDayColors(int daysInMonth, MoneyGeneral general) => [
  AppTokens.moneyGreen,
  for (var day = 1; day <= daysInMonth; day++)
    (general.days[day]?.overBudget ?? false)
        ? AppTokens.moneyRed
        : AppTokens.moneyGreen,
];

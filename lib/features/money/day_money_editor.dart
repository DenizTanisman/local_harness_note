import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/analysis_repository.dart' show formatAmount;
import '../../data/repositories/money_repository.dart';
import '../home/widgets/input_bodies.dart' show parseNum;
import 'edit_guard.dart';
import 'money_providers.dart';
import 'money_reveal.dart';

/// Password-gated edit (then delete-or-update) of one transaction. Shared by
/// the day breakdown and the monthly table. New data is never gated — only
/// changes to existing rows are.
Future<void> editTransactionFlow(
  BuildContext context,
  WidgetRef ref,
  Transaction tx,
) async {
  if (!await requireEditPassword(context)) return;
  if (!context.mounted) return;
  final result = await showDialog<_EditResult>(
    context: context,
    builder: (_) => _EditTransactionDialog(tx: tx),
  );
  if (result == null) return;
  final repo = ref.read(moneyRepositoryProvider);
  if (result.delete) {
    await repo.deleteTransaction(tx.id);
  } else {
    await repo.updateTransaction(
      tx.id,
      amount: result.amount,
      category: result.category,
      subtype: result.subtype,
      note: result.note,
    );
  }
}

/// Collapsible per-day Income / Outcome breakdown shown under the money
/// form. Tap any row to edit name / amount / note (password required).
class DayMoneyEditor extends ConsumerWidget {
  const DayMoneyEditor({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(dayTransactionsProvider(date)).value ?? const [];
    if (txs.isEmpty) return const SizedBox.shrink();
    final income = txs.where((t) => t.direction == 'income').toList();
    final outcome = txs.where((t) => t.direction == 'outcome').toList();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (income.isNotEmpty)
            _DirectionDropdown(rows: income, isIncome: true),
          if (outcome.isNotEmpty)
            _DirectionDropdown(rows: outcome, isIncome: false),
        ],
      ),
    );
  }
}

class _DirectionDropdown extends ConsumerWidget {
  const _DirectionDropdown({required this.rows, required this.isIncome});

  final List<Transaction> rows;
  final bool isIncome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reveal = ref.watch(moneyRevealProvider);
    final total = rows.fold<double>(0, (a, t) => a + t.amount);
    final dir = isIncome ? 'income' : 'outcome';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ExpansionTile(
        dense: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        title: MoneyText(
          id: 'money-day-$dir-total',
          prefix: '${isIncome ? 'Income' : 'Outcome'}: ',
          amount: '${formatAmount(total)} ₺',
          style: theme.textTheme.titleSmall,
        ),
        children: [
          for (final tx in rows)
            Builder(
              builder: (context) {
                final id = 'money-day-tx-${tx.id}';
                final shown = reveal.shows(id);
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 24, right: 12),
                  title: Text(displayCategory(tx)),
                  subtitle: tx.note == null ? null : Text(tx.note!),
                  trailing: MoneyText(
                    id: id,
                    interactive: false,
                    amount: '${isIncome ? '+' : '−'}${formatAmount(tx.amount)} ₺',
                    style: theme.textTheme.bodyMedium,
                  ),
                  // Masked → reveal; revealed → edit. Both password-gated.
                  onTap: () => shown
                      ? editTransactionFlow(context, ref, tx)
                      : revealMoneyFlow(context, ref, id),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EditResult {
  const _EditResult({
    this.delete = false,
    this.amount,
    this.category,
    this.subtype,
    this.note,
  });

  final bool delete;
  final double? amount;
  final String? category;
  final String? subtype;
  final String? note;
}

class _EditTransactionDialog extends ConsumerStatefulWidget {
  const _EditTransactionDialog({required this.tx});

  final Transaction tx;

  @override
  ConsumerState<_EditTransactionDialog> createState() =>
      _EditTransactionDialogState();
}

class _EditTransactionDialogState
    extends ConsumerState<_EditTransactionDialog> {
  late final TextEditingController _amount = TextEditingController(
    text: formatAmount(widget.tx.amount),
  );
  late final TextEditingController _subtype = TextEditingController(
    text: widget.tx.subtype ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.tx.note ?? '',
  );
  late String? _category = widget.tx.category;

  @override
  void dispose() {
    _amount.dispose();
    _subtype.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(moneyCategoriesProvider(widget.tx.direction)).value ??
        const [];
    // Keep the current category selectable even if it was since removed.
    final names = {
      for (final c in categories) c.name,
      ?_category,
    }.toList();

    return AlertDialog(
      title: Text(widget.tx.direction == 'income' ? 'Geliri düzenle' : 'Gideri düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: names.contains(_category) ? _category : null,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: [
                for (final n in names)
                  DropdownMenuItem(value: n, child: Text(n)),
              ],
              onChanged: (v) => setState(() => _category = v),
            ),
            TextField(
              controller: _amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              decoration: const InputDecoration(labelText: 'Tutar', suffixText: 'TL'),
            ),
            TextField(
              controller: _subtype,
              decoration: const InputDecoration(
                labelText: 'Alt tür (isteğe bağlı)',
              ),
            ),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'Açıklama (isteğe bağlı)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const _EditResult(delete: true)),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Sil'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () {
            final amount = parseNum(_amount.text);
            if (amount == null || amount < 0 || _category == null) return;
            Navigator.pop(
              context,
              _EditResult(
                amount: amount,
                category: _category,
                subtype: _subtype.text,
                note: _note.text,
              ),
            );
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

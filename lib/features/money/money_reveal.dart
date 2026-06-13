import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'edit_guard.dart';

/// The placeholder shown wherever a money amount is hidden.
const moneyMask = '***';

/// What money amounts are currently un-masked. Session-only: it starts fully
/// masked, and is reset both on app restart (the provider is recreated) and
/// whenever the app is backgrounded (AppShell calls [MoneyRevealNotifier.reset]),
/// so leaving and re-entering the app always re-asks for the password.
class MoneyReveal {
  const MoneyReveal({this.all = false, this.ids = const {}});

  /// Every money amount is visible this session.
  final bool all;

  /// Individually revealed spots (by reveal id), when not [all].
  final Set<String> ids;

  bool shows(String id) => all || ids.contains(id);
}

class MoneyRevealNotifier extends Notifier<MoneyReveal> {
  @override
  MoneyReveal build() => const MoneyReveal();

  void revealAll() => state = const MoneyReveal(all: true);

  void revealOne(String id) =>
      state = MoneyReveal(all: state.all, ids: {...state.ids, id});

  /// Re-hide everything (on background / app exit).
  void reset() => state = const MoneyReveal();
}

final moneyRevealProvider =
    NotifierProvider<MoneyRevealNotifier, MoneyReveal>(MoneyRevealNotifier.new);

/// Asks for the edit password, then (on success) whether to reveal only the
/// tapped amount or every money amount for this session.
Future<void> revealMoneyFlow(
  BuildContext context,
  WidgetRef ref,
  String id,
) async {
  if (!await requireEditPassword(context)) return;
  if (!context.mounted) return;
  final scope = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Tutarları göster'),
      content: const Text(
        'Sadece bu tutarı mı yoksa bu oturumdaki tüm para tutarlarını mı '
        'göstereyim?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'one'),
          child: const Text('Sadece bunu'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, 'all'),
          child: const Text('Her yeri'),
        ),
      ],
    ),
  );
  final notifier = ref.read(moneyRevealProvider.notifier);
  if (scope == 'all') {
    notifier.revealAll();
  } else if (scope == 'one') {
    notifier.revealOne(id);
  }
}

/// A money amount that is masked as [moneyMask] until revealed. [prefix] and
/// [suffix] (e.g. a label or trailing note) stay visible; only [amount] is
/// hidden. When [interactive] and masked, tapping runs [revealMoneyFlow];
/// otherwise the parent owns the tap (e.g. an edit/navigation row).
class MoneyText extends ConsumerWidget {
  const MoneyText({
    super.key,
    required this.id,
    required this.amount,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.textAlign,
    this.interactive = true,
  });

  final String id;
  final String amount;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool interactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = ref.watch(moneyRevealProvider).shows(id);
    final text = Text(
      '$prefix${shown ? amount : moneyMask}$suffix',
      style: style,
      textAlign: textAlign,
    );
    if (!interactive || shown) return text;
    return InkWell(onTap: () => revealMoneyFlow(context, ref, id), child: text);
  }
}

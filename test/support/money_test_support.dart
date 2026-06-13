import 'package:daily_tracker/features/money/money_reveal.dart';

/// Money amounts are masked (***) by default. Widget tests that assert on the
/// actual amounts add [revealAllOverride] so the numbers render unmasked.
class _RevealAll extends MoneyRevealNotifier {
  @override
  MoneyReveal build() => const MoneyReveal(all: true);
}

final revealAllOverride = moneyRevealProvider.overrideWith(_RevealAll.new);

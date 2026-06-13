import 'package:flutter/material.dart';

/// Unified date/month selector (CR-3 follow-up #5). One look, one place —
/// the top of every tab's body. Day pages and month pages bind it to their
/// own state; the visual is identical. Stateless: caller supplies value +
/// callbacks.
class PeriodBar extends StatelessWidget {
  const PeriodBar({
    super.key,
    required this.label,
    required this.onPrev,
    required this.onNext,
    this.onTapLabel,
    this.canGoNext = true,
    this.highlighted = false,
    this.onReset,
    this.resetLabel = 'Today',
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  /// Opens a picker; null disables the label tap.
  final VoidCallback? onTapLabel;

  /// false → next chevron disabled (e.g. day pages cannot go past today).
  final bool canGoNext;

  /// true → label styled as active + the reset chip shows.
  final bool highlighted;
  final VoidCallback? onReset;
  final String resetLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            key: const ValueKey('period-prev'),
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          InkWell(
            key: const ValueKey('period-label'),
            borderRadius: BorderRadius.circular(999),
            onTap: onTapLabel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: highlighted ? scheme.primary : Colors.transparent,
                border: Border.all(
                  color: highlighted ? scheme.primary : scheme.outlineVariant,
                ),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: highlighted ? scheme.onPrimary : null,
                  fontWeight: highlighted ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('period-next'),
            icon: const Icon(Icons.chevron_right),
            onPressed: canGoNext ? onNext : null,
          ),
          if (highlighted && onReset != null)
            TextButton(
              key: const ValueKey('period-reset'),
              onPressed: onReset,
              child: Text(resetLabel),
            ),
        ],
      ),
    );
  }
}

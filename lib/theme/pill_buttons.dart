import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Pill toggle (CR1-B rule 5): selected → accent gradient + glow + white
/// text; unselected → translucent card fill, thin border, secondary text.
class PillToggleButton extends StatelessWidget {
  const PillToggleButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        gradient: selected ? AppTokens.accentGradient : null,
        color: selected ? null : AppTokens.surfaceCard,
        border: selected
            ? null
            : Border.all(color: AppTokens.surfaceCardBorder),
        boxShadow: selected ? const [AppTokens.glowShadow] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class NavItem {
  const NavItem(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Floating pill navigation with a separate round action button on the
/// right: icon over label, the picked tab sits on a lighter pill that
/// slides between items.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
    required this.actionIcon,
    required this.actionTooltip,
    required this.onAction,
  });

  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final IconData actionIcon;
  final String actionTooltip;
  final VoidCallback onAction;

  static const height = 64.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: height,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppTokens.navBarFill,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                border: Border.all(color: AppTokens.navBarBorder),
                boxShadow: const [AppTokens.navShadow],
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  final w = box.maxWidth / items.length;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        left: w * index,
                        top: 0,
                        bottom: 0,
                        width: w,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppTokens.navSelectedFill,
                            borderRadius: BorderRadius.circular(
                              AppTokens.radiusPill,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: Semantics(
                                button: true,
                                selected: i == index,
                                label: items[i].label,
                                excludeSemantics: true,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                    AppTokens.radiusPill,
                                  ),
                                  onTap: () => onSelect(i),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        i == index
                                            ? items[i].selectedIcon
                                            : items[i].icon,
                                        size: 22,
                                        color: i == index
                                            ? AppTokens.accentEnd
                                            : AppTokens.textSecondary,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        items[i].label,
                                        style: text.labelSmall?.copyWith(
                                          color: i == index
                                              ? AppTokens.textPrimary
                                              : AppTokens.textSecondary,
                                          fontWeight: i == index
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: actionTooltip,
            child: Semantics(
              button: true,
              label: actionTooltip,
              excludeSemantics: true,
              // Glow on a circle outside, ink clipped to the circle inside —
              // an Ink with a shadow drew the glow as a square.
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTokens.accentGradient,
                  boxShadow: [AppTokens.glowShadow],
                ),
                child: Material(
                  type: MaterialType.transparency,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    key: const Key('nav-action'),
                    onTap: onAction,
                    child: SizedBox(
                      width: height,
                      height: height,
                      child: Icon(actionIcon, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

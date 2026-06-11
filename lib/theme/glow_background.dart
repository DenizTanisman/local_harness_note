import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Single radial glow layer per page (CR1-B `bg.glow`): blue radial light
/// focused at the upper-middle, fading to transparent. Plain gradient —
/// no BackdropFilter anywhere (scroll performance rule).
class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: 0,
          right: 0,
          height: 420,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.1,
                  colors: [
                    AppTokens.bgGlow.withValues(alpha: 0.35),
                    AppTokens.bgGlow.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

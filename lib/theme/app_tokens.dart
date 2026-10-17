import 'package:flutter/material.dart';

/// Design tokens — the ONLY place raw color values may live (CR1-B).
/// Screens must reference these; `Color(0x...)` outside lib/theme/ is
/// forbidden and enforced by test.
class AppTokens {
  AppTokens._();

  // Background
  static const bgBase = Color(0xFF050B18);
  static const bgGlow = Color(0xFF103A6E); // radial, 35% → transparent

  // Surfaces (glass look via translucency + border — NO BackdropFilter)
  static const surfaceCard = Color(0x0DFFFFFF); // white 5%
  static const surfaceCardBorder = Color(0x17FFFFFF); // white 9%
  static const surfaceInput = Color(0x0AFFFFFF); // white 4%

  // Accent
  static const accentStart = Color(0xFF2E7CF6);
  static const accentEnd = Color(0xFF5EA8FF);
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentStart, accentEnd],
  );
  static const glowShadow = BoxShadow(
    color: Color(0x592E7CF6), // accentStart 35%
    blurRadius: 18,
  );

  // Text
  static const textPrimary = Color(0xFFF2F6FF);
  static const textSecondary = Color(0xFF8FA3C8);
  static const textAccent = Color(0xFF5EA8FF);

  static const danger = Color(0xFFFF5C6C);

  // Category colours: each main #tag gets a pixel icon in one of these.
  static const catOrange = Color(0xFFFFA657);
  static const catGreen = Color(0xFF7EE787);
  static const catYellow = Color(0xFFF2CC60);
  static const catPink = Color(0xFFF778BA);
  static const catBlue = Color(0xFF79C0FF);
  static const catPurple = Color(0xFFD2A8FF);
  static const catRed = Color(0xFFFF7B72);
  static const catTeal = Color(0xFF56D4DD);
  static const catGrey = Color(0xFF8FA3C8);

  // Floating bottom navigation (pill bar + action circle)
  static const navBarFill = Color(0xF00E1A30); // navy, a step above bgBase
  static const menuFill = Color(0xFF0E1A30); // navBarFill, opaque
  static const navBarBorder = Color(0x1F5EA8FF); // accentEnd 12%
  static const navSelectedFill = Color(0x332E7CF6); // accentStart 20%
  static const navShadow = BoxShadow(
    color: Color(0x80000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // Radii
  static const radiusCard = 20.0;
  static const radiusPill = 999.0;
}

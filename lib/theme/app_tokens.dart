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

  // Data colors that must NOT follow the theme (CR1-B rules 3/5):
  /// GitHub neon green sparkline.
  static const sparkline = Color(0xFF39D353);

  /// Money over/under budget (matches HeatColors red/green).
  static const moneyRed = Color(0xFFDA3633);
  static const moneyGreen = Color(0xFF2EA043);

  /// Calorie-day "under target" warning (CR-3 §11 yellow).
  static const warn = Color(0xFFD4A72C);

  // Radii
  static const radiusCard = 20.0;
  static const radiusPill = 999.0;

  /// Categorical palette for the Money donut (CR-3 §4). Distinct hues that
  /// read on the deep-navy surface; cycled when categories exceed the list.
  static const chartPalette = [
    Color(0xFF5EA8FF),
    Color(0xFF56D364),
    Color(0xFFD4A72C),
    Color(0xFFDB6D28),
    Color(0xFFEC4899),
    Color(0xFF9E86FF),
    Color(0xFF2EA043),
    Color(0xFFF9A8D4),
  ];
}

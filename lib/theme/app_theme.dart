import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// The single (dark) theme, built exclusively from [AppTokens] (CR1-B).
ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppTokens.accentStart,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppTokens.accentStart,
        onPrimary: Colors.white,
        surface: AppTokens.bgBase,
        onSurface: AppTokens.textPrimary,
        onSurfaceVariant: AppTokens.textSecondary,
        outline: AppTokens.textSecondary,
        outlineVariant: AppTokens.surfaceCardBorder,
        error: AppTokens.danger,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppTokens.bgBase,
    appBarTheme: const AppBarTheme(
      // Transparent: the page glow shows through (CR1-B rule 6).
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppTokens.textPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppTokens.surfaceCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        side: const BorderSide(color: AppTokens.surfaceCardBorder),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppTokens.bgBase,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Color.alphaBlend(
        AppTokens.surfaceCard,
        AppTokens.bgBase,
      ),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        side: const BorderSide(color: AppTokens.surfaceCardBorder),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppTokens.bgBase,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppTokens.surfaceInput,
      labelStyle: const TextStyle(color: AppTokens.textSecondary),
      hintStyle: const TextStyle(color: AppTokens.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTokens.surfaceCardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTokens.surfaceCardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTokens.accentEnd),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppTokens.surfaceCard,
      selectedColor: AppTokens.accentStart,
      labelStyle: const TextStyle(color: AppTokens.textSecondary),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: AppTokens.surfaceCardBorder),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppTokens.accentStart,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTokens.textSecondary,
        side: const BorderSide(color: AppTokens.surfaceCardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: AppTokens.textPrimary),
      titleMedium: TextStyle(color: AppTokens.textPrimary),
      bodyLarge: TextStyle(color: AppTokens.textPrimary),
      bodyMedium: TextStyle(color: AppTokens.textPrimary),
      bodySmall: TextStyle(color: AppTokens.textSecondary),
      labelLarge: TextStyle(color: AppTokens.textSecondary),
    ),
  );
}

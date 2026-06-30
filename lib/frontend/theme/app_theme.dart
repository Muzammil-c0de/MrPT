import 'package:flutter/material.dart';

/// FitPilot brand palette.
///
/// These tokens mirror the values used by the trainer portal so every module
/// renders with the exact same premium black-and-yellow fitness identity.
class AppColors {
  const AppColors._();

  static const background = Color(0xFF090907);
  static const surface = Color(0xFF17150F);
  static const surfaceAlt = Color(0xFF211E14);
  static const charcoal = Color(0xFF0E0D0A);
  static const ink = Color(0xFFFFF8DC);
  static const muted = Color(0xFFC9B76D);
  static const yellow = Color(0xFFFFD23F);
  static const gold = Color(0xFFE4A900);
  static const amber = Color(0xFFFFE58A);
  static const line = Color(0xFF3C3314);
  static const danger = Color(0xFFFF6B6B);
  static const success = Color(0xFF7BD88F);
}

/// Shared corner radius used across cards, fields, and buttons.
const double kAppRadius = 8.0;

/// Builds the single dark theme shared by the login screen, admin console, and
/// trainer portal.
ThemeData buildFitPilotTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.yellow,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(
      primary: AppColors.yellow,
      secondary: AppColors.gold,
      tertiary: AppColors.amber,
      surface: AppColors.surface,
      onPrimary: AppColors.charcoal,
      onSurface: AppColors.ink,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kAppRadius)),
        side: BorderSide(color: AppColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.charcoal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kAppRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kAppRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.yellow),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.charcoal,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kAppRadius),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kAppRadius),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kAppRadius),
        borderSide: const BorderSide(color: AppColors.yellow, width: 1.4),
      ),
      labelStyle: const TextStyle(color: AppColors.muted),
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
  );
}

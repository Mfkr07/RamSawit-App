import 'package:flutter/material.dart';

/// Design tokens & Theme berdasarkan IBM Carbon Design System (doc/DESIGN.md).
/// - Primary: IBM Blue (#0F62FE)
/// - Neutral Ink: #161616 (Charcoal)
/// - Background Canvas: #FFFFFF / #F4F4F4
/// - Corners: Flat square (0-4px)
class AppColors {
  static const Color primary = Color(0xFF0F62FE);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF161616);
  static const Color inkMuted = Color(0xFF525252);
  static const Color inkSubtle = Color(0xFF8C8C8C);
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surface1 = Color(0xFFF4F4F4);
  static const Color surface2 = Color(0xFFE0E0E0);
  static const Color hairline = Color(0xFFE0E0E0);
  static const Color hairlineStrong = Color(0xFF161616);

  // Semantics
  static const Color success = Color(0xFF24A148);
  static const Color warning = Color(0xFFF1C21B);
  static const Color error = Color(0xFFDA1E28);
  static const Color info = Color(0xFF0F62FE);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.ink,
        onSecondary: AppColors.canvas,
        error: AppColors.error,
        onError: AppColors.canvas,
        surface: AppColors.canvas,
        onSurface: AppColors.ink,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.canvas,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          side: BorderSide(color: AppColors.hairline, width: 1.0),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
          borderSide: BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
          borderSide: BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

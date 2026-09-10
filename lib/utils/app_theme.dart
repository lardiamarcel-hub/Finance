import 'package:flutter/material.dart';

/// Palette chaleureuse et très lisible en plein soleil : orange comme
/// couleur principale (dynamisme du marché), vert pour "accepté / payé",
/// rouge pour "refusé", jaune pour "en attente".
class AppColors {
  static const orange = Color(0xFFFF7A1A);
  static const orangeDark = Color(0xFFCC5F00);
  static const green = Color(0xFF1CA84B);
  static const red = Color(0xFFE5393B);
  static const amber = Color(0xFFFFB300);
  static const background = Color(0xFFFFFBF6);
  static const surface = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF241C15);
  static const textMuted = Color(0xFF6B5F55);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        primary: AppColors.orange,
        secondary: AppColors.green,
        error: AppColors.red,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
        fontSizeFactor: 1.0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(64),
          textStyle: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 1,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.orangeDark,
          minimumSize: const Size.fromHeight(60),
          side: const BorderSide(color: AppColors.orange, width: 2),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
        hintStyle: const TextStyle(fontSize: 18, color: AppColors.textMuted),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

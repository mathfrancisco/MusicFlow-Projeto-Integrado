import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF121318);
  static const surface = Color(0xFF1C1E26);
  static const surfaceHighlight = Color(0xFF262933);
  static const accent = Color(0xFF7C5CFF);
  static const textPrimary = Color(0xFFE8E6F0);
  static const textSecondary = Color(0xFFA9A7B8);

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accent,
      onPrimary: background,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
    );
    final textTheme = ThemeData.dark()
        .textTheme
        .apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        )
        .copyWith(
          headlineMedium: ThemeData.dark()
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: ThemeData.dark()
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600, color: textPrimary),
          bodySmall: ThemeData.dark()
              .textTheme
              .bodySmall
              ?.copyWith(color: textSecondary),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        foregroundColor: textPrimary,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: surfaceHighlight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHighlight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3A3E4C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF16181F),
        indicatorColor: accent.withValues(alpha: 0.24),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color =
              states.contains(WidgetState.selected) ? accent : textSecondary;
          return IconThemeData(color: color);
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: background,
      ),
    );
  }
}

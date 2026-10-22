import 'package:flutter/material.dart';

/// Casino-felt inspired Material 3 theme: deep green with a gold accent, in
/// light and dark variants.
class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF1B5E20); // deep felt green
  static const Color gold = Color(0xFFFFC107);
  static const Color darkBackground = Color(0xFF0E1512);
  static const Color darkSurface = Color(0xFF16201B);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    ).copyWith(secondary: gold, tertiary: gold);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? darkBackground : null,
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? darkSurface : scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkBackground : null,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}

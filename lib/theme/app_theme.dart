import 'package:flutter/material.dart';

/// Slate blue theme for the Weather app (light + dark).
class AppTheme {
  static const Color slateBlue = Color(0xFF185FA5);
  static const Color blueLight = Color(0xFFE6F1FB);
  static const Color blueDark = Color(0xFF042C53);
  static const Color blueOnDark = Color(0xFF85B7EB);

  /// Background and text colors for the big current-weather card.
  static Color heroBackground(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF14283D) : blueLight;
  static Color heroText(Brightness b) =>
      b == Brightness.dark ? Colors.white : blueDark;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? blueOnDark : slateBlue;
    final onPrimary = isDark ? blueDark : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: slateBlue,
        brightness: brightness,
      ).copyWith(
        primary: primary,
        onPrimary: onPrimary,
        secondary: primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E5E5),
          ),
        ),
      ),
    );
  }
}
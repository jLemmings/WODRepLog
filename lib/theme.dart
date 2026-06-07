import 'package:flutter/material.dart';

class AppTheme {
  static const Color _surface = Color(0xFF0E1520);
  static const Color _surfaceHigh = Color(0xFF182A3E);
  static const Color _blue = Color(0xFF347FFF);
  static const Color _green = Color(0xFF2AD27D);
  static const Color _orange = Color(0xFFFF6B2C);
  static const Color _red = Color(0xFFFF4D5E);

  static ThemeData get lightTheme {
    return _base(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _base(Brightness.dark);
  }

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(seedColor: _blue, brightness: brightness).copyWith(
          primary: _blue,
          onPrimary: Colors.white,
          secondary: _green,
          tertiary: _orange,
          error: _red,
          surface: isDark ? _surface : const Color(0xFFF7F8FA),
          surfaceContainerHighest: isDark ? _surfaceHigh : Colors.white,
          primaryContainer: const Color(0xFF244F78),
          secondaryContainer: const Color(0xFF123D2A),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Roboto',
      textTheme: Typography.material2021(platform: TargetPlatform.android).white
          .apply(
            bodyColor: isDark ? Colors.white : const Color(0xFF111318),
            displayColor: isDark ? Colors.white : const Color(0xFF111318),
          ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF111318),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _blue,
          minimumSize: const Size.fromHeight(54),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _blue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: isDark ? 0.07 : 0.92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

extension CustomColorScheme on ColorScheme {
  Color get amrapColor => const Color(0xFF347FFF);
  Color get forTimeColor => const Color(0xFF2AD27D);
  Color get emomColor => const Color(0xFF5DA0FF);
  Color get tabataColor => const Color(0xFFFF6B2C);
}

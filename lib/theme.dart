// theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Primary color scheme
      primaryColor: const Color(0xFF1C1C1E), // Dark Charcoal
      scaffoldBackgroundColor: const Color(0xFFEFEFF4), // Soft White

      // Color scheme with secondary and tertiary colors
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        accentColor: const Color(0xFF007AFF), // Electric Blue
      ).copyWith(
        secondary: const Color(0xFF32FF7E), // Neon Green
        tertiary: const Color(0xFFFF9500), // Fiery Orange
        error: const Color(0xFFFF3B30), // Crimson Red
        primary: const Color(0xFF1C1C1E), // Dark Charcoal
      ),

      // Text theme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF8E8E93)), // Cool Gray
        bodyMedium: TextStyle(color: Color(0xFF1C1C1E)), // Dark Charcoal
      ),

      // Button styling
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF007AFF), // Electric Blue for buttons
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      // Primary color scheme
      primaryColor: const Color(0xFF1C1C1E), // Dark Charcoal
      primaryColorDark: const Color(0xFF2C2C2E),
      scaffoldBackgroundColor: const Color(0xFF2C2C2E),

      // Text theme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFEFEFF4)), // Cool Gray
        bodyMedium: TextStyle(color: Color(0xFFEFEFF4)), // Dark Charcoal
      ),

      // Button styling
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFFFF9500), // Electric Blue for buttons
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF007AFF),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1C1E),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        accentColor: const Color(0xFF007AFF), // Electric Blue
      )
          .copyWith(
            secondary: const Color(0xFF32FF7E), // Neon Green
            tertiary: const Color(0xFFFF9500), // Fiery Orange
            error: const Color(0xFFFF3B30), // Crimson Red
            primary: const Color(0xFF1C1C1E), // Dark Charcoal
          )
          .copyWith(secondary: const Color(0xFF007AFF)),
    );
  }
}

extension CustomColorScheme on ColorScheme {
  Color get amrapColor => const Color(0xFFFF5722); // Amrap color (Orange)
  Color get forTimeColor => const Color(0xFF4CAF50); // For Time color (Green)
  Color get emomColor => const Color(0xFF2196F3); // Emom color (Blue)
  Color get tabataColor => const Color(0xFFFFC107); // Tabata color (Amber)
}

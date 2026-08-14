// lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    indicatorColor: Colors.grey.shade800,
    brightness: Brightness.light,
    canvasColor: Color(0xFFCCEC0C),
    hoverColor: Color.fromARGB(255, 145, 170, 0),
    scaffoldBackgroundColor: const Color(0xFFF3F3F3),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.grey.shade800,
      onError: Colors.red.shade900,
      brightness: Brightness.light,
    ),
    cardColor: Colors.white,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.teal,
      ), // 🆕 ganti 'primary' yang deprecated
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontFamily: 'Roboto', color: Colors.grey.shade800, fontSize: 42),
      bodyLarge: TextStyle(fontFamily: 'Roboto', color: Colors.grey.shade800, fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'Roboto', color: Colors.grey.shade800, fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    indicatorColor: Colors.white,
    canvasColor: Color(0xFFCCEC0C),
    hoverColor: Color.fromARGB(255, 145, 170, 0),
    scaffoldBackgroundColor: Colors.grey.shade800,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.grey.shade800,
      brightness: Brightness.dark,
      onError: Colors.red.shade900,
    ),
    cardColor: Colors.grey.shade700,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.teal),
    ),
     textTheme: TextTheme(
      titleLarge: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 42),
      bodyLarge: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

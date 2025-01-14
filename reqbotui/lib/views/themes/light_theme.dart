import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  var kColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 96, 59, 181),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: kColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: kColorScheme.primaryContainer,
      foregroundColor: kColorScheme.onPrimaryContainer,
    ),
    cardTheme: CardTheme(
      color: kColorScheme.secondaryContainer,
      margin: const EdgeInsets.all(16),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black),
    ),
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kColorScheme.primary,
        foregroundColor: kColorScheme.onPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: kColorScheme.primaryContainer,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kColorScheme.primary),
      ),
    ),
  );
}

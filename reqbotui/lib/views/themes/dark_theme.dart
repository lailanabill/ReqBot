import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  var kDarkColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 5, 99, 125),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: kDarkColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: kDarkColorScheme.primaryContainer,
      foregroundColor: kDarkColorScheme.onPrimaryContainer,
    ),
    cardTheme: CardTheme(
      color: kDarkColorScheme.secondaryContainer,
      margin: const EdgeInsets.all(16),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
    ),
    scaffoldBackgroundColor: Colors.black,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kDarkColorScheme.primary,
        foregroundColor: kDarkColorScheme.onPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: kDarkColorScheme.primaryContainer,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kDarkColorScheme.primary),
      ),
    ),
  );
}

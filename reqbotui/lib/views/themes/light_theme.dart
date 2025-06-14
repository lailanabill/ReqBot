import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  // Use the original blue color as the primary color
  const primaryColor = Color.fromARGB(255, 0, 54, 218);
  
  var kColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: primaryColor,
  ).copyWith(
    primary: primaryColor,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    onSurfaceVariant: Colors.black54,
    surfaceVariant: Colors.grey,
    outline: const Color(0xFFEEEEEE),
    shadow: Colors.black,
    error: Colors.red,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: kColorScheme,
    scaffoldBackgroundColor: Colors.white,
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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
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
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );
}

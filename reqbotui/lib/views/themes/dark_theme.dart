import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  // Use a complementary dark blue for dark theme
  const primaryColor = Color.fromARGB(255, 0, 54, 218);
  const darkPrimaryColor =
      Color.fromARGB(255, 100, 150, 255); // Lighter blue for dark mode

  var kDarkColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: primaryColor,
  ).copyWith(
    primary: darkPrimaryColor,
    onPrimary: Colors.black,
    surface: const Color(0xFF1E1E1E), // Dark grey surface
    onSurface: Colors.white,
    onSurfaceVariant: Colors.white70,
    surfaceVariant: Colors.grey.shade800,
    outline: Colors.grey.shade700,
    shadow: Colors.black,
    error: Colors.redAccent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: kDarkColorScheme,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: kDarkColorScheme.primaryContainer,
      foregroundColor: kDarkColorScheme.onPrimaryContainer,
    ),
    cardTheme: CardThemeData(
      color: kDarkColorScheme.secondaryContainer,
      margin: const EdgeInsets.all(16),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.black,
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
        borderSide: BorderSide(color: darkPrimaryColor),
      ),
    ),
  );
}

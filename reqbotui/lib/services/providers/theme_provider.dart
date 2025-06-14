import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Load theme preference from shared preferences
  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Toggle between light and dark mode
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    
    // Save preference to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    
    notifyListeners();
  }

  // Set specific theme mode
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    
    // Save preference to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    
    notifyListeners();
  }
} 
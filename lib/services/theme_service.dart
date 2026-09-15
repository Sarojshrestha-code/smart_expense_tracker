 import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._internal();

  ThemeService._internal();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool('darkMode') ?? false;

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    // Change the UI immediately.
    _isDarkMode = value;
    notifyListeners();

    // Save the preference in the background.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }
}
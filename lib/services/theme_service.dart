import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService instance =
      ThemeService._internal();

  ThemeService._internal();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode =
        prefs.getBool('darkMode') ?? false;

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'darkMode',
      value,
    );

    notifyListeners();
  }
}
import 'package:flutter/material.dart';

import '../services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService;

  ThemeProvider({ThemeService? themeService})
      : _themeService = themeService ?? ThemeService.instance {
    _themeService.addListener(_onThemeChanged);
  }

  // =========================
  // GETTERS
  // =========================

  bool get isDarkMode => _themeService.isDarkMode;

  ThemeMode get themeMode => _themeService.themeMode;

  // =========================
  // LOAD THEME
  // =========================

  Future<void> loadTheme() async {
    await _themeService.loadTheme();
    notifyListeners();
  }

  // =========================
  // CHANGE THEME
  // =========================

  Future<void> setDarkMode(bool value) async {
    await _themeService.setDarkMode(value);
  }

  // =========================
  // LISTEN FOR SERVICE CHANGES
  // =========================

  void _onThemeChanged() {
    notifyListeners();
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  late ThemeMode _themeMode;

  ThemeController(this._prefs) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // We can't know for sure without context, but strictly speaking "isDarkMode"
      // usually implies the forced override.
      // However, for the switch state, if it's system, we might want to show
      // based on system platform brightness, but we don't have context here.
      // For the simplified setting toggle (Light vs Dark), we might treat "System"
      // as strictly not-dark or handle it differently.
      // Let's assume the switch is a simple binary toggle for now which overrides system.
      // OR, better: The user asked for "possibility to choose darkmode".
      // Let's implement toggle functionality: if user toggles ON, set Dark.
      // If OFF, set Light. System default is just the starting point.
      return _themeMode == ThemeMode.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void _loadTheme() {
    final themeString = _prefs.getString(_themeKey);
    if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    String value;
    switch (mode) {
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _prefs.setString(_themeKey, value);
  }

  /// Toggles between Light and Dark.
  /// If currently System, it sets to Dark if we want to enable it,
  /// or Light if we want to disable it.
  Future<void> toggleTheme(bool isDark) async {
    await updateThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

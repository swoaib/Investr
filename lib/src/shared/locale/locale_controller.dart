import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController with ChangeNotifier {
  static const String _localeKey = 'locale_code';
  final SharedPreferences _prefs;
  Locale? _locale;

  LocaleController(this._prefs) {
    _loadLocale();
  }

  Locale? get locale => _locale;

  void _loadLocale() {
    final localeCode = _prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    } else {
      _locale = null; // System default
    }
    notifyListeners();
  }

  Future<void> updateLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();

    if (locale != null) {
      await _prefs.setString(_localeKey, locale.languageCode);
    } else {
      await _prefs.remove(_localeKey);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  static const String _showStockTickerKey = 'show_stock_ticker';
  static const String _showStockLogosKey = 'show_stock_logos';
  static const String _defaultLandingPageKey = 'default_landing_page';
  final SharedPreferences _prefs;
  late bool _showStockTicker;
  late bool _showStockLogos;
  late String _defaultLandingPage;

  SettingsController(this._prefs) {
    _loadSettings();
  }

  bool get showStockTicker => _showStockTicker;
  bool get showStockLogos => _showStockLogos;
  String get defaultLandingPage => _defaultLandingPage;

  void _loadSettings() {
    _showStockTicker = _prefs.getBool(_showStockTickerKey) ?? true;
    _showStockLogos = _prefs.getBool(_showStockLogosKey) ?? true;
    _defaultLandingPage = _prefs.getString(_defaultLandingPageKey) ?? 'stocks';
    notifyListeners();
  }

  Future<void> toggleStockTicker(bool value) async {
    _showStockTicker = value;
    notifyListeners();
    await _prefs.setBool(_showStockTickerKey, value);
  }

  Future<void> toggleStockLogos(bool value) async {
    _showStockLogos = value;
    notifyListeners();
    await _prefs.setBool(_showStockLogosKey, value);
  }

  Future<void> setDefaultLandingPage(String value) async {
    _defaultLandingPage = value;
    notifyListeners();
    await _prefs.setString(_defaultLandingPageKey, value);
  }
}

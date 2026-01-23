import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  static const String _showStockTickerKey = 'show_stock_ticker';
  final SharedPreferences _prefs;
  late bool _showStockTicker;

  SettingsController(this._prefs) {
    _loadSettings();
  }

  bool get showStockTicker => _showStockTicker;

  void _loadSettings() {
    _showStockTicker = _prefs.getBool(_showStockTickerKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleStockTicker(bool value) async {
    _showStockTicker = value;
    notifyListeners();
    await _prefs.setBool(_showStockTickerKey, value);
  }
}

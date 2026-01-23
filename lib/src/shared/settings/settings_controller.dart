import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  static const String _showStockTickerKey = 'show_stock_ticker';
  static const String _showStockLogosKey = 'show_stock_logos';
  final SharedPreferences _prefs;
  late bool _showStockTicker;
  late bool _showStockLogos;

  SettingsController(this._prefs) {
    _loadSettings();
  }

  bool get showStockTicker => _showStockTicker;
  bool get showStockLogos => _showStockLogos;

  void _loadSettings() {
    _showStockTicker = _prefs.getBool(_showStockTickerKey) ?? true;
    _showStockLogos = _prefs.getBool(_showStockLogosKey) ?? true;
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
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyController extends ChangeNotifier {
  static const String _currencyKey = 'app_currency';
  String _currency = 'USD'; // Default

  String get currency => _currency;

  CurrencyController() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString(_currencyKey) ?? 'USD';
    notifyListeners();
  }

  Future<void> setCurrency(String newCurrency) async {
    if (_currency != newCurrency) {
      _currency = newCurrency;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, _currency);
      notifyListeners();
    }
  }
}

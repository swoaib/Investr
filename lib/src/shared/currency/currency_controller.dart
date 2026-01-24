import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/currency_repository.dart';

class CurrencyController extends ChangeNotifier {
  static const String _currencyKey = 'app_currency';
  final CurrencyRepository _repository = CurrencyRepository();

  String _currency = 'USD'; // Default
  double _exchangeRate = 1.0; // USD to _currency

  String get currency => _currency;
  double get exchangeRate => _exchangeRate;

  String get currencySymbol {
    return NumberFormat.simpleCurrency(name: _currency).currencySymbol;
  }

  CurrencyController() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString(_currencyKey) ?? 'USD';
    await _updateExchangeRate();
    notifyListeners();
  }

  Future<void> setCurrency(String newCurrency) async {
    if (_currency != newCurrency) {
      _currency = newCurrency;
      await _updateExchangeRate();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, _currency);
      notifyListeners();
    }
  }

  Future<void> _updateExchangeRate() async {
    if (_currency == 'USD') {
      _exchangeRate = 1.0;
    } else {
      final rate = await _repository.getExchangeRate('USD', _currency);
      if (rate != null) {
        _exchangeRate = rate;
      }
    }
  }
}

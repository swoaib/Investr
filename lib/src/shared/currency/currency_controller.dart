import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/currency/domain/currency_conversion.dart';
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

  static const String _conversionsKey = 'saved_currency_conversions';

  List<CurrencyConversion> _savedConversions = [];
  List<CurrencyConversion> get savedConversions => _savedConversions;

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString(_currencyKey) ?? 'USD';

    // Load saved conversions
    final savedJson = prefs.getStringList(_conversionsKey);
    if (savedJson != null) {
      _savedConversions = savedJson
          .map((str) => CurrencyConversion.fromJson(json.decode(str)))
          .toList();
    }

    await _updateExchangeRate();
    notifyListeners();
  }

  Future<void> addConversion(CurrencyConversion conversion) async {
    _savedConversions.add(conversion);
    await _saveConversions();
    notifyListeners();
  }

  Future<void> removeConversion(CurrencyConversion conversion) async {
    _savedConversions.remove(conversion);
    await _saveConversions();
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

  Future<void> _saveConversions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _savedConversions
        .map((c) => json.encode(c.toJson()))
        .toList();
    await prefs.setStringList(_conversionsKey, jsonList);
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/currency/domain/currency_conversion.dart';
import '../services/analytics_service.dart';
import 'data/currency_repository.dart';

class CurrencyController extends ChangeNotifier {
  static const String _currencyKey = 'app_currency';
  final CurrencyRepository _repository = CurrencyRepository();

  final AnalyticsService _analyticsService;

  String _currency = 'USD'; // Default
  double _exchangeRate = 1.0; // USD to _currency

  String get currency => _currency;
  double get exchangeRate => _exchangeRate;

  String get currencySymbol {
    return NumberFormat.simpleCurrency(name: _currency).currencySymbol;
  }

  CurrencyController({required AnalyticsService analyticsService})
    : _analyticsService = analyticsService {
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
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addConversion(CurrencyConversion conversion) async {
    _savedConversions.add(conversion);
    await _saveConversions();
    notifyListeners();
    await _analyticsService.logAddCurrencyConversion(
      baseCurrency: conversion.baseCurrency,
      targetCurrency: conversion.targetCurrency,
    );
  }

  Future<void> removeConversion(CurrencyConversion conversion) async {
    _savedConversions.remove(conversion);
    notifyListeners();
    await _saveConversions();
    await _analyticsService.logRemoveCurrencyConversion(
      baseCurrency: conversion.baseCurrency,
      targetCurrency: conversion.targetCurrency,
    );
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

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

  Future<void> _saveConversions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _savedConversions
        .map((c) => json.encode(c.toJson()))
        .toList();
    await prefs.setStringList(_conversionsKey, jsonList);
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> refreshSavedConversions() async {
    if (_savedConversions.isEmpty) return;

    // Don't show shimmer for background refreshes
    // _isLoading = true;
    // notifyListeners();

    try {
      bool hasChanges = false;
      for (int i = 0; i < _savedConversions.length; i++) {
        final conversion = _savedConversions[i];
        var newRate = await _repository.getExchangeRate(
          conversion.baseCurrency,
          conversion.targetCurrency,
        );

        // Smart Fallback Logic for Refresh
        if (newRate == null) {
          final rateToUSD = await _repository.getExchangeRate(
            conversion.baseCurrency,
            'USD',
          );
          final rateFromUSD = await _repository.getExchangeRate(
            'USD',
            conversion.targetCurrency,
          );

          if (rateToUSD != null && rateFromUSD != null) {
            newRate = rateToUSD * rateFromUSD;
            // Maintain viaUSD status implies logical correctness of retry
          }
        }

        if (newRate != null && newRate != conversion.rate) {
          _savedConversions[i] = CurrencyConversion(
            id: conversion.id,
            baseCurrency: conversion.baseCurrency,
            targetCurrency: conversion.targetCurrency,
            rate: newRate,
            amount: conversion.amount,
            viaUSD: conversion.viaUSD,
          );
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await _saveConversions();
      }

      _lastUpdated = DateTime.now();
      notifyListeners();
    } finally {
      // _isLoading = false;
      // notifyListeners();
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

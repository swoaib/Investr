import 'package:flutter/material.dart';
import 'package:investr/src/features/market_data/domain/stock.dart';
import 'package:investr/src/features/market_data/presentation/stock_list_controller.dart';
import 'package:investr/src/shared/theme/theme_controller.dart';

class MockStockListController extends ChangeNotifier
    implements StockListController {
  @override
  Future<void> loadStocks() async {} // No-op for tests

  @override
  Future<void> searchStock(String query) async {}

  @override
  bool get isLoading => false;

  @override
  List<Stock> get stocks => [];

  @override
  String? get error => null;
}

class MockThemeController extends ChangeNotifier implements ThemeController {
  @override
  ThemeMode get themeMode => ThemeMode.system;

  @override
  bool get isDarkMode => false;

  @override
  Future<void> updateThemeMode(ThemeMode mode) async {}

  @override
  Future<void> toggleTheme(bool isDark) async {}
}

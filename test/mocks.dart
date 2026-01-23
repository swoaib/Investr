import 'package:flutter/material.dart';
import 'package:investr/src/shared/services/analytics_service.dart';
import 'package:investr/src/features/market_data/domain/stock.dart';
import 'package:investr/src/features/market_data/presentation/stock_list_controller.dart';
import 'package:investr/src/shared/theme/theme_controller.dart';
import 'package:investr/src/features/market_data/data/stock_repository.dart';

class MockStockListController extends ChangeNotifier
    implements StockListController {
  @override
  Future<void> loadStocks() async {} // No-op for tests

  @override
  Future<void> searchStock(String query) async {}

  @override
  void clearSearch() {}

  @override
  Future<void> addToWatchlist(Stock stock, {int? insertAt}) async {}

  @override
  Future<void> removeFromWatchlist(Stock stock) async {}

  @override
  void reorderStocks(int oldIndex, int newIndex) {}

  @override
  bool isInWatchlist(String symbol) => false;

  @override
  bool get isLoading => false;

  @override
  bool get isSearching => false;

  @override
  List<Stock> get stocks => [];

  @override
  List<Stock> get searchResults => [];

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

class MockStockRepository implements StockRepository {
  @override
  String get apiKey => 'test_key';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAnalyticsService implements AnalyticsService {
  @override
  NavigatorObserver get observer => NavigatorObserver();

  @override
  Future<void> logScreenView(String screenName) async {}

  @override
  Future<void> logSearch(String query) async {}

  @override
  Future<void> logCalculatorUsage({
    required String symbol,
    required double result,
    required double wacc,
    required double growthRate,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

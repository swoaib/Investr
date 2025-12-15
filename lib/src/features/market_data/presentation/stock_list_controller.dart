import 'package:flutter/material.dart';
import '../data/stock_repository.dart';
import '../domain/stock.dart';

class StockListController extends ChangeNotifier {
  final StockRepository _repository;

  StockListController({StockRepository? repository})
    : _repository = repository ?? StockRepository();

  List<Stock> _stocks = [];
  List<Stock> get stocks => _stocks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadStocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stocks = await _repository.getWatchlistStocks();
    } catch (e) {
      _error = 'Failed to load stock data. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchStock(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First, try to find the ticker (supports both symbol and name search)
      final tickerResult = await _repository.searchTicker(query);

      if (tickerResult != null) {
        // Found a match, now get the stock data
        final stock = await _repository.getStock(
          tickerResult.symbol,
          name: tickerResult.name,
        );

        if (stock != null) {
          // Add to top of list
          _stocks.removeWhere((s) => s.symbol == stock.symbol);
          _stocks.insert(0, stock);
        } else {
          _error = 'Could not load stock data';
        }
      } else {
        _error = 'Stock not found for "$query"';
      }
    } catch (e) {
      _error = 'Error searching stock';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

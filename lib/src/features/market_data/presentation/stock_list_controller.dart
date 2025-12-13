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
      final stock = await _repository.getStock(query);
      if (stock != null) {
        // Add to top of list if found
        _stocks.removeWhere((s) => s.symbol == stock.symbol);
        _stocks.insert(0, stock);
      } else {
        _error = 'Stock not found';
      }
    } catch (e) {
      _error = 'Error searching stock';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

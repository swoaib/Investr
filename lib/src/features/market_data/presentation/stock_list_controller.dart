import 'package:flutter/material.dart';
import '../data/stock_repository.dart';
import '../domain/stock.dart';

class StockListController extends ChangeNotifier {
  final StockRepository _repository;

  StockListController({StockRepository? repository})
    : _repository = repository ?? StockRepository();

  List<Stock> _stocks = [];
  List<Stock> get stocks => _stocks;

  // Search state
  List<Stock> _searchResults = [];
  List<Stock> get searchResults => _searchResults;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadStocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stocks = await _repository.getWatchlistStocks();

      // Load sparkline data for each stock in parallel
      final stocksWithSparklines = await Future.wait(
        stocks.map((stock) async {
          try {
            final sparkline = await _repository.getIntradayHistory(
              stock.symbol,
            );
            return stock.copyWithSparkline(sparkline);
          } catch (e) {
            return stock; // Return stock without sparkline on error
          }
        }),
      );

      _stocks = stocksWithSparklines;
    } catch (e) {
      _error = 'Failed to load stock data. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchStock(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _isLoading = true;
    _isSearching = true;
    _error = null;
    _searchResults = [];
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
          _searchResults = [stock];
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

  void clearSearch() {
    _isSearching = false;
    _searchResults = [];
    _error = null;
    notifyListeners();
  }

  /// Adds a stock from search results to the watchlist
  void addToWatchlist(Stock stock) {
    // Check if stock is already in watchlist
    if (_stocks.any((s) => s.symbol == stock.symbol)) {
      return; // Already in watchlist
    }
    _stocks.insert(0, stock);
    notifyListeners();
  }

  /// Checks if a stock is in the watchlist
  bool isInWatchlist(String symbol) {
    return _stocks.any((s) => s.symbol == symbol);
  }
}

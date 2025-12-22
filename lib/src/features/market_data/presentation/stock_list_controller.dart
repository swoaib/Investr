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
      // Get all matching tickers
      final tickerResults = await _repository.searchTicker(query);

      if (tickerResults.isNotEmpty) {
        // Fetch stock data for all found tickers in parallel
        final stocks = await Future.wait(
          tickerResults.map(
            (ticker) => _repository.getStock(ticker.symbol, name: ticker.name),
          ),
        );

        // Filter out any that failed to load (nulls)
        final validStocks = stocks.whereType<Stock>().toList();

        if (validStocks.isNotEmpty) {
          _searchResults = validStocks;
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
  Future<void> addToWatchlist(Stock stock) async {
    // Check if stock is already in watchlist
    if (_stocks.any((s) => s.symbol == stock.symbol)) {
      return; // Already in watchlist
    }

    // Add to local list immediately for UI responsiveness
    _stocks.insert(0, stock);
    notifyListeners();

    // Persist
    await _repository.addToWatchlist(stock.symbol, stock.companyName);
  }

  /// Remove a stock from the watchlist
  Future<void> removeFromWatchlist(Stock stock) async {
    _stocks.removeWhere((s) => s.symbol == stock.symbol);
    notifyListeners();

    await _repository.removeFromWatchlist(stock.symbol);
  }

  /// Checks if a stock is in the watchlist
  bool isInWatchlist(String symbol) {
    return _stocks.any((s) => s.symbol == symbol);
  }
}

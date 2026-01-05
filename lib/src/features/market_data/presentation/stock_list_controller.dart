import 'package:flutter/material.dart';
import '../data/stock_repository.dart';
import 'dart:async';
import '../domain/stock.dart';
// import '../domain/price_point.dart'; // Unused import

class StockListController extends ChangeNotifier {
  final StockRepository _repository;
  Timer? _pollingTimer;

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

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> loadStocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Enhance stocks with previousClose for calculation
      // Since stocks are from "Yesterday" (or previous close), their 'price' is the 'previousClose' for today.
      var fetchedStocks = await _repository.getWatchlistStocks();

      // Auto-Recovery: If fetching yields empty list (but no error), keys might be bad or empty. Reset.
      if (fetchedStocks.isEmpty) {
        await _repository.resetToDefaults();
        fetchedStocks = await _repository.getWatchlistStocks();
      }

      final stocksWithRef = fetchedStocks
          .map((s) => s.copyWith(previousClose: s.price))
          .toList();

      // Load sparklines
      final stocksWithSparklines = await Future.wait(
        stocksWithRef.map((stock) async {
          try {
            final sparkline = await _repository.getIntradayHistory(
              stock.symbol,
            );
            return stock.copyWithSparkline(sparkline);
          } catch (e) {
            return stock;
          }
        }),
      );

      _stocks = stocksWithSparklines;

      // Start Polling (REST API)
      _startPolling();
    } catch (e) {
      // Log error internally or to crash reporting service
      _error = 'Failed to load stock data. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _updateStockPrices();
    });
  }

  Future<void> _updateStockPrices() async {
    if (_stocks.isEmpty) return;

    // Ideally, use a batch endpoint. For now, we loop or use a modified repository method.
    // To be efficient, we'll fetch details for each.
    // NOTE: In a production app with rate limits, we should be careful here.
    // We will iterate and update in place.

    for (int i = 0; i < _stocks.length; i++) {
      try {
        final updatedStock = await _repository.getQuote(
          _stocks[i],
        ); // Refresh price

        _stocks[i] = _stocks[i].copyWith(
          price: updatedStock.price,
          change: updatedStock.change,
          changePercent: updatedStock.changePercent,
        );

        // Optionally refresh sparkline if needed, but maybe too heavy for 30s poll.
        // Let's stick to price for now.
      } catch (e) {
        // ignore error
      }
    }
    notifyListeners();
  }

  // void _onStockUpdate(Map<String, dynamic> event) { ... } // Removed WebSocket

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
        // Fetch stock data for only the top 15 relevant tickers to avoid 429 Rate Limits
        final topResults = tickerResults.take(15).toList();

        final stocks = await Future.wait(
          topResults.map(
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
    _stocks.add(stock);
    notifyListeners();

    // Persist
    await _repository.addToWatchlist(stock.symbol, stock.companyName);

    // Fetch sparkline and update
    try {
      final sparkline = await _repository.getIntradayHistory(stock.symbol);
      final index = _stocks.indexWhere((s) => s.symbol == stock.symbol);
      if (index != -1) {
        _stocks[index] = _stocks[index].copyWithSparkline(sparkline);
        notifyListeners();
      }
    } catch (e) {
      // ignore
    }

    // Subscribe to polling (automatic via _startPolling logic or explicit update)
    // If we want immediate update, maybe fetch details again? Already done in addToWatchlist.
    // _marketDataService.subscribe([stock.symbol]); // Removed WebSocket
  }

  /// Remove a stock from the watchlist
  Future<void> removeFromWatchlist(Stock stock) async {
    _stocks.removeWhere((s) => s.symbol == stock.symbol);
    notifyListeners();

    await _repository.removeFromWatchlist(stock.symbol);
  }

  /// Reorders stocks in the watchlist
  void reorderStocks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Stock item = _stocks.removeAt(oldIndex);
    _stocks.insert(newIndex, item);
    notifyListeners();

    _repository.updateWatchlistOrder(_stocks);
  }

  /// Checks if a stock is in the watchlist
  bool isInWatchlist(String symbol) {
    return _stocks.any((s) => s.symbol == symbol);
  }
}

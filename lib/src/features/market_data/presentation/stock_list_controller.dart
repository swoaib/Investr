import 'package:flutter/material.dart';
import '../data/stock_repository.dart';
import '../data/market_data_service.dart';
import '../domain/stock.dart';

class StockListController extends ChangeNotifier {
  final StockRepository _repository;
  MarketDataService? _marketDataService;

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
    _marketDataService?.dispose();
    super.dispose();
  }

  Future<void> loadStocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stocks = await _repository.getWatchlistStocks();

      // Initialize MarketDataService if not already
      _marketDataService ??= MarketDataService(apiKey: _repository.apiKey);
      _marketDataService!.connect();

      // Enhance stocks with previousClose for calculation
      // Since stocks are from "Yesterday" (or previous close), their 'price' is the 'previousClose' for today.
      final stocksWithRef = stocks
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

      // Subscribe to real-time updates
      if (_marketDataService != null) {
        // Setup listener if first time
        if (!_isListening) {
          _marketDataService!.updates.listen(_onStockUpdate);
          _isListening = true;
        }
        _marketDataService!.subscribe(_stocks.map((s) => s.symbol).toList());
      }
    } catch (e) {
      _error = 'Failed to load stock data. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isListening = false;

  void _onStockUpdate(Map<String, dynamic> event) {
    if (_stocks.isEmpty) return;

    final symbol = event['sym'];
    final price = (event['c'] as num?)?.toDouble();

    if (symbol != null && price != null) {
      final index = _stocks.indexWhere((s) => s.symbol == symbol);
      if (index != -1) {
        final currentStock = _stocks[index];
        // Calculate change based on stored previousClose (Yesterday's Close)
        final prevClose = currentStock.previousClose ?? currentStock.price;

        // Calculate new change
        final change = price - prevClose;
        final changePercent = (prevClose != 0)
            ? (change / prevClose) * 100
            : 0.0;

        var updatedStock = currentStock.copyWith(
          price: price,
          change: change,
          changePercent: changePercent,
        );

        _stocks[index] = updatedStock;
        notifyListeners();
      }
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
      debugPrint('Error fetching sparkline for new stock: $e');
    }

    // Subscribe to real-time updates
    if (_marketDataService != null) {
      _marketDataService!.subscribe([stock.symbol]);
    }
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

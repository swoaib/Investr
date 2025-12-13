import 'package:flutter/foundation.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';
import '../domain/stock.dart';
import '../domain/price_point.dart';

class StockRepository {
  final YahooFinanceDailyReader _yahooReader = const YahooFinanceDailyReader();

  // Hardcoded list of popular stocks for the dashboard to simulate a "Watchlist"
  final Map<String, String> _watchlist = {
    'AAPL': 'Apple Inc.',
    'GOOGL': 'Alphabet Inc.',
    'TSLA': 'Tesla Inc.',
    'MSFT': 'Microsoft Corp.',
    'AMZN': 'Amazon.com Inc.',
    'NFLX': 'Netflix Inc.',
    'META': 'Meta Platforms',
    'NVDA': 'NVIDIA Corp.',
  };

  /// Fetches current data for the watchlist.
  /// Note: The package `yahoo_finance_data_reader` is mostly for historical data,
  /// but we can get the latest available day to simulate "current" price for this demo.
  Future<List<Stock>> getWatchlistStocks() async {
    List<Stock> stocks = [];

    final futures = _watchlist.entries.map((entry) async {
      try {
        final symbol = entry.key;
        final name = entry.value;

        // Fetch daily data
        YahooFinanceResponse response = await _yahooReader.getDailyDTOs(symbol);
        List<dynamic> candles = response.candlesData;

        if (candles.isNotEmpty) {
          var latestCandle = candles.last;
          double currentPrice = (latestCandle.close as num).toDouble();
          double openPrice = (latestCandle.open as num).toDouble();

          double change = currentPrice - openPrice;
          double changePercent = (change / openPrice) * 100;

          return Stock(
            symbol: symbol,
            companyName: name,
            price: currentPrice,
            change: change,
            changePercent: changePercent,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching data for ${entry.key}: $e');
        }
      }
      return null;
    });

    final results = await Future.wait(futures);
    stocks = results.whereType<Stock>().toList();
    return stocks;
  }

  /// Fetches data for a single stock symbol.
  Future<Stock?> getStock(String symbol) async {
    try {
      final response = await _yahooReader.getDailyDTOs(symbol);
      final candles = response.candlesData;

      if (candles.isNotEmpty) {
        final latestCandle = candles.last;
        final currentPrice = (latestCandle.close as num).toDouble();
        final openPrice = (latestCandle.open as num).toDouble();
        final change = currentPrice - openPrice;
        final changePercent = (change / openPrice) * 100;

        return Stock(
          symbol: symbol.toUpperCase(),
          companyName: symbol
              .toUpperCase(), // API doesn't provide name easily here
          price: currentPrice,
          change: change,
          changePercent: changePercent,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching stock $symbol: $e');
      }
    }
    return null;
  }

  /// Fetches historical data for a stock symbol.
  /// [interval] is not directly supported by this free package (it defaults to daily),
  /// but we can simulate ranges by filtering the returned daily data.
  Future<List<PricePoint>> getStockHistory(String symbol) async {
    try {
      // YahooFinanceDailyReader gets all available daily history by default usually
      // or we can try to filter if the package allows (checking source code is ideal,
      // but assuming it returns a decent amount of history).
      final response = await _yahooReader.getDailyDTOs(symbol);
      final candles = response.candlesData;

      if (candles.isNotEmpty) {
        return candles.map((candle) {
          // candle.date is usually a timestamp or DateTime?
          // The package often uses a specific format or dynamic.
          // Let's assume date is parsable or is a timestamp.
          // Looking at common usage of this package:
          // candle might satisfy YahooFinanceCandleData which has 'date' as DateTime? or int?
          // YahooFinanceCandleData usually has date as DateTime
          DateTime date = candle.date;

          return PricePoint(
            date: date,
            price: (candle.close as num).toDouble(),
          );
        }).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching history for $symbol: $e');
      }
    }
    return [];
  }
}

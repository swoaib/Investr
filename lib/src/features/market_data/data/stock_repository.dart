import 'package:flutter/foundation.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';
import '../domain/stock.dart';

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

    for (var entry in _watchlist.entries) {
      try {
        final symbol = entry.key;
        final name = entry.value;

        // Fetch daily data
        // We do not have a direct "Realtime quote" API in this free package easily,
        // so we take the last known candle.
        YahooFinanceResponse response = await _yahooReader.getDailyDTOs(symbol);

        List<dynamic> candles = response.candlesData;

        if (candles.isNotEmpty) {
          // Candles are usually sorted, but let's ensure we get the latest
          // The package usually returns a list of YahooFinanceCandleData
          // but due to dynamic typing in the map return, we verify.

          // Actually getDailyDTOs returns a Map with 'candles' which is a List<YahooFinanceCandleData>
          // Let's verify the type or work with dynamic

          var latestCandle = candles.last;
          // Assuming candle has close, open, etc.

          double currentPrice = (latestCandle.close as num).toDouble();
          double openPrice = (latestCandle.open as num).toDouble();

          // Calculate daily change based on Open vs Close (Approximate for demo)
          double change = currentPrice - openPrice;
          double changePercent = (change / openPrice) * 100;

          stocks.add(
            Stock(
              symbol: symbol,
              companyName: name,
              price: currentPrice,
              change: change,
              changePercent: changePercent,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching data for ${entry.key}: $e');
        }
        // In a real app, handle error state or retry.
      }
    }
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
}

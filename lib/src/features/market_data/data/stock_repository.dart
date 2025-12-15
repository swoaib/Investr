import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../domain/stock.dart';
import '../domain/price_point.dart';

class StockRepository {
  final String _apiKey = 'gWdDRuo8TM3Mmy5cXuuwxbFuzpLpuRn1';
  final String _baseUrl = 'https://api.polygon.io';

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
  /// Uses "Grouped Daily" endpoint to fetch all data in 1 API call to avoid rate limits.
  Future<List<Stock>> getWatchlistStocks() async {
    List<Stock> stocks = [];
    try {
      // 1. Calculate the most recent trading day (typically yesterday)
      // Grouped Daily data is available for the previous trading day.
      DateTime date = DateTime.now().subtract(const Duration(days: 1));
      while (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        date = date.subtract(const Duration(days: 1));
      }
      // Simple loop to find previous weekday. Note: This doesn't account for holidays.
      // If a holiday, the API might return empty, but for this demo it's robust enough.

      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/grouped/locale/us/market/stocks/$dateStr?adjusted=true&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null) {
          // Create a map for O(1) lookup or just filter
          // We only care about stocks in our _watchlist
          for (var item in results) {
            final String ticker = item['T'];
            if (_watchlist.containsKey(ticker)) {
              // Found a watchlist item
              final double currentPrice = (item['c'] as num).toDouble();
              final double openPrice = (item['o'] as num).toDouble();
              final double change = currentPrice - openPrice;
              final double changePercent = (openPrice != 0)
                  ? (change / openPrice) * 100
                  : 0.0;

              stocks.add(
                Stock(
                  symbol: ticker,
                  companyName: _watchlist[ticker]!,
                  price: currentPrice,
                  change: change,
                  changePercent: changePercent,
                ),
              );
            }
          }
        }
      } else {
        if (kDebugMode)
          print('Failed to fetch group data: ${response.statusCode}');
        // Fallback: If group fetch fails (e.g. 403 or Holiday), return empty list or try individual fallback?
        // For now, return empty to avoid hanging.
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching watchlist: $e');
    }

    // Sort to maintain order if needed, or just return what we found
    return stocks;
  }

  /// Fetches data for a single stock symbol.
  /// Uses "Previous Close" endpoint which is generally free-tier accessible.
  Future<Stock?> getStock(String symbol, {String? name}) async {
    try {
      // /v2/aggs/ticker/{stocksTicker}/prev
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/prev?adjusted=true&apiKey=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final tickerData = results.first;
          final double currentPrice = (tickerData['c'] as num).toDouble();
          final double openPrice = (tickerData['o'] as num).toDouble();
          final double change = currentPrice - openPrice;
          final double changePercent = (openPrice != 0)
              ? (change / openPrice) * 100
              : 0.0;

          return Stock(
            symbol: symbol.toUpperCase(),
            companyName: name ?? symbol.toUpperCase(),
            price: currentPrice,
            change: change,
            changePercent: changePercent,
          );
        }
      } else {
        if (kDebugMode)
          print('Failed to fetch stock $symbol: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching stock $symbol: $e');
    }
    return null;
  }

  /// Fetches detailed fundamental data (Market Cap, Employees, Description, etc.)
  /// and returns a NEW Stock object with these fields populated.
  Future<Stock> getStockDetails(Stock stock) async {
    double? marketCap;
    String? description;
    int? employees;
    double? peRatio;
    double? earningsPerShare;
    double? dividendYield;

    try {
      // 1. Ticker Details v3 (Market Cap, Description, Employees)
      final detailsUrl = Uri.parse(
        '$_baseUrl/v3/reference/tickers/${stock.symbol}?apiKey=$_apiKey',
      );
      final detailsResponse = await http.get(detailsUrl);

      if (detailsResponse.statusCode == 200) {
        final data = json.decode(detailsResponse.body);
        final results = data['results'];
        if (results != null) {
          marketCap = (results['market_cap'] as num?)?.toDouble();
          description = results['description'];
          employees = results['total_employees'];
        }
      }

      // 2. Financials (EPS for PE Ratio)
      // Get most recent annual or quarterly report
      final financialsUrl = Uri.parse(
        '$_baseUrl/vX/reference/financials?ticker=${stock.symbol}&limit=1&apiKey=$_apiKey',
      );
      final financialsResponse = await http.get(financialsUrl);

      if (financialsResponse.statusCode == 200) {
        final data = json.decode(financialsResponse.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final financials = results.first['financials'];
          final incomeStatement = financials?['income_statement'];

          // Try to find basic_earnings_per_share
          final epsNode = incomeStatement?['basic_earnings_per_share'];
          if (epsNode != null) {
            earningsPerShare = (epsNode['value'] as num?)?.toDouble();
          }
        }
      }

      if (earningsPerShare != null && earningsPerShare != 0) {
        peRatio = stock.price / earningsPerShare;
      }

      // 3. Dividends (Yield)
      final dividendsUrl = Uri.parse(
        '$_baseUrl/v3/reference/dividends?ticker=${stock.symbol}&limit=1&apiKey=$_apiKey',
      );
      final divResponse = await http.get(dividendsUrl);

      if (divResponse.statusCode == 200) {
        final data = json.decode(divResponse.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final cashAmount = (results.first['cash_amount'] as num?)?.toDouble();
          final frequency =
              results.first['frequency']
                  as int?; // e.g. 4 for quarterly? Polygon frequency is int

          if (cashAmount != null && frequency != null && stock.price > 0) {
            // Frequency: 1=Annually, 2=Semi, 4=Quarterly, 12=Monthly?
            // Polygon docs say frequency is number of times per year.
            dividendYield = (cashAmount * frequency) / stock.price * 100;
          }
        }
      }

      return Stock(
        symbol: stock.symbol,
        companyName: stock.companyName,
        price: stock.price,
        change: stock.change,
        changePercent: stock.changePercent,
        marketCap: marketCap,
        description: description,
        employees: employees,
        peRatio: peRatio,
        earningsPerShare: earningsPerShare,
        dividendYield: dividendYield,
      );
    } catch (e) {
      if (kDebugMode) print('Error fetching details for ${stock.symbol}: $e');
      return stock;
    }
  }

  /// Fetches historical data for a stock symbol.
  /// Defaults to 1 Year of daily data.
  Future<List<PricePoint>> getStockHistory(String symbol) async {
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 365 * 2)); // 2 years
      final dateFormat = DateFormat('yyyy-MM-dd');

      // /v2/aggs/ticker/{stocksTicker}/range/{multiplier}/{timespan}/{from}/{to}
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/range/1/day/${dateFormat.format(from)}/${dateFormat.format(now)}?adjusted=true&sort=asc&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null) {
          return results.map((candle) {
            // 't' is Unix Msec timestamp
            final date = DateTime.fromMillisecondsSinceEpoch(candle['t']);
            final close = (candle['c'] as num).toDouble();
            return PricePoint(date: date, price: close);
          }).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching history for $symbol: $e');
    }

    return [];
  }

  /// Fetches intraday data for the "1D" chart.
  /// Uses recent 30-minute aggregates to provide a meaningful curve while respecting free tier limits.
  /// Attempts to find the last valid trading day's data.
  Future<List<PricePoint>> getIntradayHistory(String symbol) async {
    try {
      // Find the last likely trading day (Yesterday or Friday if today is Weekend/Monday)
      // Note: Data might be delayed 15 mins or EOD on free tier, enabling 30-min bars helps smoothing.
      DateTime date = DateTime.now().subtract(const Duration(days: 1));
      while (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        date = date.subtract(const Duration(days: 1));
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      // /v2/aggs/ticker/{ticker}/range/{multiplier}/{timespan}/{from}/{to}
      // Using 30-minute intervals for the single day
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/range/30/minute/$dateStr/$dateStr?adjusted=true&sort=asc&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          return results.map((candle) {
            final date = DateTime.fromMillisecondsSinceEpoch(candle['t']);
            final close = (candle['c'] as num).toDouble();
            return PricePoint(date: date, price: close);
          }).toList();
        } else {
          // Fallback: If 30-min data is empty (might happen on free tier for previous day sometimes?),
          // try fetching 1-hour bars or just return empty to trigger fallback logic in UI
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching intraday for $symbol: $e');
    }
    return [];
  }

  /// Searches for a stock ticker by symbol or name.
  /// Returns the best matching ticker symbol and name.
  Future<({String symbol, String name})?> searchTicker(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query.toUpperCase());
      final url = Uri.parse(
        '$_baseUrl/v3/reference/tickers?search=$encodedQuery&active=true&limit=10&apiKey=$_apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          // Prioritize exact ticker match
          for (var result in results) {
            if ((result['ticker'] as String).toUpperCase() ==
                query.toUpperCase()) {
              return (
                symbol: result['ticker'] as String,
                name: result['name'] as String,
              );
            }
          }
          // Otherwise return first result
          return (
            symbol: results.first['ticker'] as String,
            name: results.first['name'] as String,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error searching ticker for $query: $e');
    }
    return null;
  }
}

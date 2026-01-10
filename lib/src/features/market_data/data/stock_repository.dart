import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../domain/stock.dart';
import '../domain/price_point.dart';
import '../domain/earnings_point.dart';
import '../../valuation/domain/dcf_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockRepository {
  late final String _apiKey;
  String get apiKey => _apiKey;
  final String _baseUrl = 'https://api.polygon.io';

  StockRepository() {
    _apiKey = dotenv.env['POLYGON_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      if (kDebugMode) {
        print('WARNING: POLYGON_API_KEY is missing in .env');
      }
    }
  }

  static const String _watchlistKey = 'watchlist_v2';

  // Default stocks for new users
  final Map<String, String> _defaultWatchlist = {
    'I:SPX': 'S&P 500',
    'I:DJI': 'Dow Jones',
    'I:NDX': 'Nasdaq 100', // Polygon uses I:NDX
    'AAPL': 'Apple Inc.',
    'GOOGL': 'Alphabet Inc.',
    'TSLA': 'Tesla Inc.',
    'MSFT': 'Microsoft Corp.',
    'AMZN': 'Amazon.com Inc.',
    'NVDA': 'Nvidia Corp.',
  };

  /// Fetches current data for the watchlist.
  /// Polygon doesn't have a free "batch" endpoint easily.
  /// We'll fetch individually for now to be safe, or use Grouped Daily (Previous Close) if we want "yesterday's" close for all.
  /// But "current price" (delayed 15min) requires individual calls or specific endpoints.
  /// For now, lets fetch individually to match the exact interface logic.
  Future<List<Stock>> getWatchlistStocks() async {
    List<Stock> stocks = [];
    try {
      final watchlistMap = await _loadWatchlistMap();
      if (watchlistMap.isEmpty) return [];

      // Parallel fetch
      final futures = watchlistMap.entries.map((entry) async {
        final symbol = entry.key;
        final name = entry.value;
        return await getStock(symbol, name: name);
      });

      final results = await Future.wait(futures);
      stocks = results.whereType<Stock>().toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching watchlist: $e');
    }
    return stocks;
  }

  /// Fetches data for a single stock symbol.
  /// Uses "Previous Close" endpoint for daily data, or "Aggs" for latest.
  /// Previous Close is reliable for free tier.
  Future<Stock?> getStock(String symbol, {String? name}) async {
    try {
      // Endpoint: /v2/aggs/ticker/{stocksTicker}/prev
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/prev?adjusted=true&apiKey=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['resultsCount'] > 0) {
          final result = data['results'][0];

          final double price = (result['c'] as num).toDouble();
          final double open = (result['o'] as num).toDouble();

          final double change = price - open;
          final double changePercent = (open != 0)
              ? (change / open) * 100
              : 0.0;

          return Stock(
            symbol: data['ticker'],
            companyName:
                name ?? data['ticker'], // Polygon doesn't return Name here
            price: price,
            change: change,
            changePercent: changePercent,
            previousClose:
                open, // Using Open as proxy for "baseline" of the candle
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching stock $symbol: $e');
    }
    return null;
  }

  /// Fetches detailed fundamental data (Market Cap, Employees, Description, etc.)
  /// Uses Ticker Details v3.
  Future<Stock> getStockDetails(Stock stock) async {
    try {
      // Endpoint: /v3/reference/tickers/{ticker}
      final url = Uri.parse(
        '$_baseUrl/v3/reference/tickers/${stock.symbol}?apiKey=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'];
          return stock.copyWith(
            companyName: results['name'] ?? stock.companyName,
            description: results['description'] ?? '',
            employees: (results['total_employees'] as num?)?.toInt() ?? 0,
            marketCap: (results['market_cap'] as num?)?.toDouble() ?? 0.0,
            peRatio:
                0.0, // Polygon Ticker Details doesn't usually have PE. Need financials.
            dividendYield: 0.0, // Need separate endpoint
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching details for ${stock.symbol}: $e');
    }
    return stock;
  }

  Future<Stock> getQuote(Stock stock) async {
    // Just reuse getStock for now.
    final updated = await getStock(stock.symbol, name: stock.companyName);
    return updated ?? stock;
  }

  /// Fetches historical earnings (EPS) and Revenue for the Earnings chart.
  Future<List<EarningsPoint>> getEarningsHistory(
    String symbol, {
    String frequency = 'quarterly',
  }) async {
    // Earnings not easily available on Polygon Free Tier (usually).
    return [];
  }

  /// Fetches historical data (Daily Bars).
  Future<List<PricePoint>> getStockHistory(String symbol) async {
    try {
      // 1 Year of History.
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 365));
      final toStr = now.toIso8601String().split('T')[0];
      final fromStr = from.toIso8601String().split('T')[0];

      // Endpoint: /v2/aggs/ticker/{stocksTicker}/range/1/day/{from}/{to}
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/range/1/day/$fromStr/$toStr?adjusted=true&sort=asc&limit=500&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['resultsCount'] > 0) {
          final List<dynamic> results = data['results'];
          return results.map((candle) {
            // Polygon timestamp is milliseconds
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

  Future<List<PricePoint>> getIntradayHistory(String symbol) async {
    try {
      // Fetch last 4 days to ensure coverage over weekends/holidays
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 4));
      final toStr = now.toIso8601String().split('T')[0];
      final fromStr = from.toIso8601String().split('T')[0];

      // Endpoint: /v2/aggs/ticker/{ticker}/range/5/minute/...
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/range/5/minute/$fromStr/$toStr?adjusted=true&sort=asc&limit=5000&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['resultsCount'] > 0) {
          final List<dynamic> results = data['results'];
          final points = results.map((candle) {
            final date = DateTime.fromMillisecondsSinceEpoch(candle['t']);
            final close = (candle['c'] as num).toDouble();
            return PricePoint(date: date, price: close);
          }).toList();

          return filterForMarketHours(points);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching intraday for $symbol: $e');
    }
    return [];
  }

  Future<List<PricePoint>> getWeeklyHistory(String symbol) async {
    return []; // Placeholder
  }

  Future<List<PricePoint>> getMonthlyHistory(String symbol) async {
    return []; // Placeholder
  }

  /// Searches for a stock ticker.
  Future<List<({String symbol, String name})>> searchTicker(
    String query,
  ) async {
    try {
      // Endpoint: /v3/reference/tickers?search={query}
      final url = Uri.parse(
        '$_baseUrl/v3/reference/tickers?search=$query&active=true&sort=ticker&order=asc&limit=10&apiKey=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final List<dynamic> results = data['results'];
          return results
              .map(
                (result) => (
                  symbol: result['ticker'] as String,
                  name: result['name'] as String,
                ),
              )
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error searching ticker for $query: $e');
    }
    return [];
  }

  // Encryption/Persistence Helpers (Same as before)
  Future<Map<String, String>> _loadWatchlistMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_watchlistKey);
    if (jsonString == null) {
      await _saveWatchlistMap(_defaultWatchlist);
      return _defaultWatchlist;
    }
    try {
      final List<dynamic> list = json.decode(jsonString);
      if (list.isEmpty) {
        await _saveWatchlistMap(_defaultWatchlist);
        return _defaultWatchlist;
      }
      return {for (var item in list) item['symbol']: item['name']};
    } catch (e) {
      return _defaultWatchlist;
    }
  }

  Future<void> _saveWatchlistMap(Map<String, String> map) async {
    final prefs = await SharedPreferences.getInstance();
    final list = map.entries
        .map((entry) => {'symbol': entry.key, 'name': entry.value})
        .toList();
    await prefs.setString(_watchlistKey, json.encode(list));
  }

  Future<void> addToWatchlist(String symbol, String name) async {
    final current = await _loadWatchlistMap();
    if (!current.containsKey(symbol)) {
      current[symbol] = name;
      await _saveWatchlistMap(current);
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    final current = await _loadWatchlistMap();
    if (current.containsKey(symbol)) {
      current.remove(symbol);
      await _saveWatchlistMap(current);
    }
  }

  Future<void> updateWatchlistOrder(List<Stock> stocks) async {
    final newMap = {for (var s in stocks) s.symbol: s.companyName};
    await _saveWatchlistMap(newMap);
  }

  Future<void> resetToDefaults() async {
    await _saveWatchlistMap(_defaultWatchlist);
  }

  /// Fetches data required for DCF calculation.
  Future<DCFData?> getDCFData(String symbol) async {
    try {
      // 1. Get Current Price (Previous Close)
      final priceUrl = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/prev?adjusted=true&apiKey=$_apiKey',
      );
      final priceResponse = await http.get(priceUrl);
      double price = 0.0;
      if (priceResponse.statusCode == 200) {
        final data = json.decode(priceResponse.body);
        if (data['resultsCount'] > 0) {
          price = (data['results'][0]['c'] as num).toDouble();
        }
      }

      // Endpoint: /vX/reference/financials?ticker={ticker}
      final financialsUrl = Uri.parse(
        '$_baseUrl/vX/reference/financials?ticker=$symbol&limit=1&apiKey=$_apiKey',
      );
      final finResponse = await http.get(financialsUrl);

      if (finResponse.statusCode == 200) {
        final data = json.decode(finResponse.body);
        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'] as List<dynamic>;
          if (results.isNotEmpty) {
            final financials = results[0]['financials'];
            final income = financials?['income_statement'];
            final balance = financials?['balance_sheet'];
            final cashFlow = financials?['cash_flow_statement'];

            // Shares Outstanding
            final sharesNode =
                income?['weighted_average_shares_outstanding_diluted'] ??
                income?['basic_average_shares'];
            final double shares =
                (sharesNode?['value'] as num?)?.toDouble() ?? 0;

            // Free Cash Flow
            final double operatingCashFlow =
                (cashFlow?['net_cash_flow_from_operating_activities']?['value']
                        as num?)
                    ?.toDouble() ??
                0;
            final double investingCashFlow =
                (cashFlow?['net_cash_flow_from_investing_activities']?['value']
                        as num?)
                    ?.toDouble() ??
                0;
            final double freeCashFlow =
                operatingCashFlow +
                investingCashFlow; // Investing usually negative

            // Net Debt
            double totalDebt =
                (balance?['long_term_debt']?['value'] as num?)?.toDouble() ?? 0;
            // If 'debt' is present it might be total debt
            if (balance?['debt'] != null) {
              totalDebt =
                  (balance?['debt']['value'] as num?)?.toDouble() ?? totalDebt;
            }
            final double cash =
                (balance?['cash_and_cash_equivalents']?['value'] as num?)
                    ?.toDouble() ??
                0;
            final double shortTermInvestments =
                (balance?['short_term_investments']?['value'] as num?)
                    ?.toDouble() ??
                0;

            final double netDebt = totalDebt - (cash + shortTermInvestments);

            return DCFData(
              symbol: symbol,
              freeCashFlow: freeCashFlow,
              netDebt: netDebt,
              sharesOutstanding: shares,
              price: price,
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching DCF data for $symbol: $e');
    }
    return null;
  }

  /// Filters a list of price points to only include those within regular market hours (09:30 - 16:00 ET).
  /// Handles DST automatically.
  List<PricePoint> filterForMarketHours(List<PricePoint> points) {
    if (points.isEmpty) return [];

    return points.where((p) {
      final utcTime = p.date.toUtc();
      final isDST = isUSDST(utcTime);

      final openHour = isDST ? 13 : 14;
      final closeHour = isDST ? 20 : 21;

      if (utcTime.weekday >= 6) return false;

      final hour = utcTime.hour;
      final minute = utcTime.minute;

      if (hour < openHour || hour > closeHour) return false;
      if (hour == openHour && minute < 30) return false;
      if (hour == closeHour && minute > 0) return false;

      return true;
    }).toList();
  }

  /// Checks if a given UTC time is within US Daylight Saving Time.
  /// DST starts on the second Sunday in March and ends on the first Sunday in November.
  bool isUSDST(DateTime utcDate) {
    final year = utcDate.year;

    // Find second Sunday in March
    DateTime marchDstStart = DateTime.utc(year, 3, 1);
    int marchSundayCount = 0;
    while (marchSundayCount < 2) {
      if (marchDstStart.weekday == DateTime.sunday) {
        marchSundayCount++;
      }
      if (marchSundayCount < 2) {
        marchDstStart = marchDstStart.add(const Duration(days: 1));
      }
    }
    // Set to 2:00 AM EST which is 7:00 AM UTC (Standard) or 6:00 AM UTC?
    // Actually DST change happens at 2AM local.
    // EST is UTC-5. EDT is UTC-4.
    // Change happens when Standard Time reaches 2AM (becoming 3AM EDT).
    // So 2AM EST is 7AM UTC.
    marchDstStart = marchDstStart.add(const Duration(hours: 7)); // 7:00 UTC

    // Find first Sunday in November
    DateTime novDstEnd = DateTime.utc(year, 11, 1);
    while (novDstEnd.weekday != DateTime.sunday) {
      novDstEnd = novDstEnd.add(const Duration(days: 1));
    }
    // Change happens at 2AM EDT (becoming 1AM EST).
    // 2AM EDT is 6AM UTC.
    novDstEnd = novDstEnd.add(const Duration(hours: 6)); // 6:00 UTC

    return utcDate.isAfter(marchDstStart) && utcDate.isBefore(novDstEnd);
  }
}

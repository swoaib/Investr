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
  final String _baseUrl = 'https://financialmodelingprep.com';

  StockRepository() {
    _apiKey = dotenv.env['FMP_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      if (kDebugMode) {
        print('WARNING: FMP_API_KEY is missing in .env');
      }
    }
  }

  static const String _watchlistKey = 'watchlist_v4';

  // Default stocks for new users
  // Default stocks for new users
  final Map<String, String> _defaultWatchlist = {
    '^GSPC': 'S&P 500', // FMP uses ^GSPC
    '^DJI': 'Dow Jones', // FMP uses ^DJI
    //'^NDX': 'Nasdaq 100', // FMP uses ^NDX
    '^N225': 'Nikkei 225', // FMP uses ^N225
    'AAPL': 'Apple Inc.',
    'GOOGL': 'Alphabet Inc.',
    'TSLA': 'Tesla Inc.',
    'MSFT': 'Microsoft Corp.',
    'AMZN': 'Amazon.com Inc.',
    'NVDA': 'Nvidia Corp.',
  };

  /// Fetches current data for the watchlist.
  /// Uses individual requests in parallel to avoid "Premium Endpoint" (402) batch errors.
  /// Fetches current data for the watchlist.
  /// Uses individual requests in parallel to avoid "Premium Endpoint" (402) batch errors.
  /// Also fetches intraday history for sparklines.
  Future<List<Stock>> getWatchlistStocks() async {
    try {
      final watchlistMap = await _loadWatchlistMap();
      if (watchlistMap.isEmpty) return [];

      // Fetch all stocks and their history in parallel
      final futures = watchlistMap.entries.map((entry) async {
        final symbol = entry.key;
        final name = entry.value;

        // Run both requests for this symbol concurrently
        final results = await Future.wait([
          getStock(symbol, name: name),
          getIntradayHistory(symbol),
        ]);

        final stock = results[0] as Stock?;
        final history = results[1] as List<PricePoint>;

        if (stock != null) {
          return stock.copyWithSparkline(history);
        }
        return null;
      });

      final results = await Future.wait(futures);
      return results.whereType<Stock>().toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching watchlist: $e');
      return [];
    }
  }

  /// Fetches data for a single stock symbol.
  /// Uses "Previous Close" endpoint for daily data, or "Aggs" for latest.
  /// Previous Close is reliable for free tier.
  Future<Stock?> getStock(String symbol, {String? name}) async {
    try {
      // Endpoint: /stable/quote?symbol={symbol}
      // "v3/quote" is legacy. "stable/quote" is the new standard.
      final url = Uri.parse(
        '$_baseUrl/stable/quote?symbol=$symbol&apikey=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        if (jsonResponse is Map) {
          if (kDebugMode) {
            print('FMP API Error for $symbol: $jsonResponse');
          }
          // API returned an error object (e.g. invalid key)
          return null;
        }

        final List<dynamic> data = jsonResponse as List<dynamic>;
        if (data.isNotEmpty) {
          final result = data[0];

          final double price = (result['price'] as num?)?.toDouble() ?? 0.0;
          // open is unused
          final double previousClose =
              (result['previousClose'] as num?)?.toDouble() ?? 0.0;
          final double change = (result['change'] as num?)?.toDouble() ?? 0.0;
          final double changePercent =
              (result['changesPercentage'] as num?)?.toDouble() ?? 0.0;

          return Stock(
            symbol: result['symbol'],
            companyName: name ?? result['name'] ?? result['symbol'],
            price: price,
            change: change,
            changePercent: changePercent,
            previousClose: previousClose,
          );
        }
      } else {
        if (kDebugMode) {
          print('FMP API HTTP Error ${response.statusCode}: ${response.body}');
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
      // Endpoint: /api/v3/profile/{symbol}
      final url = Uri.parse(
        '$_baseUrl/api/v3/profile/${stock.symbol}?apikey=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final result = data[0];
          return stock.copyWith(
            companyName: result['companyName'] ?? stock.companyName,
            description: result['description'] ?? '',
            employees: (result['fullTimeEmployees'] is String)
                ? int.tryParse(result['fullTimeEmployees']) ?? 0
                : (result['fullTimeEmployees'] as num?)?.toInt() ?? 0,
            marketCap: (result['mktCap'] as num?)?.toDouble() ?? 0.0,
            peRatio: 0.0, // FMP Profile doesn't have PE consistently here.
            dividendYield: 0.0,
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

      // Endpoint: /api/v3/historical-price-full/{symbol}?from={from}&to={to}
      final url = Uri.parse(
        '$_baseUrl/api/v3/historical-price-full/$symbol?from=$fromStr&to=$toStr&apikey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['historical'] != null) {
          final List<dynamic> historical = data['historical'];
          return historical
              .map((candle) {
                // FMP date is "YYYY-MM-DD"
                final date = DateTime.parse(candle['date']);
                final close = (candle['close'] as num).toDouble();
                return PricePoint(date: date, price: close);
              })
              .toList()
              .reversed
              .toList(); // FMP returns newest first
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching history for $symbol: $e');
    }
    return [];
  }

  Future<List<PricePoint>> getIntradayHistory(String symbol) async {
    try {
      // Intraday (1min/5min) endpoints are restricted (403 Forbidden - Legacy).
      // We fall back to Daily EOD data which is available on the free/basic tier.
      // Endpoint: /stable/historical-price-eod/light?symbol={symbol}
      // This ensures we always have *some* sparkline data.
      final url = Uri.parse(
        '$_baseUrl/stable/historical-price-eod/light?symbol=$symbol&apikey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          final points = <PricePoint>[];
          // Limit to last 30 days for a relevant sparkline/graph
          // (Data comes newest first)
          final limit = 30;
          var count = 0;

          for (var item in jsonResponse) {
            if (count >= limit) break;
            if (item is Map) {
              // Date format: "YYYY-MM-DD"
              final dateStr = item['date'] as String?;
              // API EOD Light returns 'price', not 'close' usually.
              // We check both to be safe.
              final price =
                  (item['price'] as num?)?.toDouble() ??
                  (item['close'] as num?)?.toDouble();

              if (dateStr != null && price != null) {
                points.add(
                  PricePoint(date: DateTime.parse(dateStr), price: price),
                );
                count++;
              }
            }
          }
          // Reverse to make it chronological (Oldest -> Newest)
          return points.reversed.toList();
        }
      } else {
        if (kDebugMode) {
          print('FMP EOD Error ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching intraday fallback for $symbol: $e');
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
      // Endpoint: /api/v3/search?query={query}&limit=10
      final url = Uri.parse(
        '$_baseUrl/api/v3/search?query=$query&limit=10&apikey=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (result) => (
                symbol: result['symbol'] as String,
                name: result['name'] as String,
              ),
            )
            .toList();
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
      // 1. Get Current Price (Quote)
      final priceUrl = Uri.parse(
        '$_baseUrl/api/v3/quote/$symbol?apikey=$_apiKey',
      );
      final priceResponse = await http.get(priceUrl);
      double price = 0.0;
      if (priceResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(priceResponse.body);
        if (data.isNotEmpty) {
          price = (data[0]['price'] as num).toDouble();
        }
      }

      // Needs multiple endpoints for FMP: Income, Balance Sheet, Cash Flow
      // We'll fetch latest annual reports
      final incomeUrl = Uri.parse(
        '$_baseUrl/api/v3/income-statement/$symbol?limit=1&apikey=$_apiKey',
      );
      final balanceUrl = Uri.parse(
        '$_baseUrl/api/v3/balance-sheet-statement/$symbol?limit=1&apikey=$_apiKey',
      );
      final cashFlowUrl = Uri.parse(
        '$_baseUrl/api/v3/cash-flow-statement/$symbol?limit=1&apikey=$_apiKey',
      );

      final results = await Future.wait([
        http.get(incomeUrl),
        http.get(balanceUrl),
        http.get(cashFlowUrl),
      ]);

      if (results.every((r) => r.statusCode == 200)) {
        final incomeData = json.decode(results[0].body) as List<dynamic>;
        final balanceData = json.decode(results[1].body) as List<dynamic>;
        final cashFlowData = json.decode(results[2].body) as List<dynamic>;

        if (incomeData.isNotEmpty &&
            balanceData.isNotEmpty &&
            cashFlowData.isNotEmpty) {
          final income = incomeData[0];
          final balance = balanceData[0];
          final cashFlow = cashFlowData[0];

          final double shares =
              (income['weightedAverageShsOutDil'] as num?)?.toDouble() ?? 0;
          final double freeCashFlow =
              (cashFlow['freeCashFlow'] as num?)?.toDouble() ?? 0;
          final double netDebt = (balance['netDebt'] as num?)?.toDouble() ?? 0;

          return DCFData(
            symbol: symbol,
            freeCashFlow: freeCashFlow,
            netDebt: netDebt,
            sharesOutstanding: shares,
            price: price,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching DCF data for $symbol: $e');
    }
    return null;
  }

  /// Filters price points to keep only regular market hours (09:30 - 16:00 ET).
  /// FMP returns dates in ET (Wall Clock). We parse them as-is and check the hour/minute.
  /// Also filters to return only the LATEST trading day found in the data.
  /// Filters price points to keep only the LATEST trading day found in the data.
  /// Does NOT filter by hours (keeps pre-market/after-hours) to ensure sparklines have data to show.
  List<PricePoint> filterForMarketHours(List<PricePoint> points) {
    if (points.isEmpty) return [];

    // Sort just in case (though usually sorted)
    points.sort((a, b) => a.date.compareTo(b.date));

    // If data is daily (hours are all 00:00), don't filter by "market hours" of the day.
    // Just return the sorted points.
    // The simplified EOD endpoint returns daily data, so filtering by "Latest Day"
    // would result in a single point, which breaks the sparkline.
    return points;
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
    // Change happens at 2AM local. 2AM EST is 7AM UTC.
    marchDstStart = marchDstStart.add(const Duration(hours: 7));

    // Find first Sunday in November
    DateTime novDstEnd = DateTime.utc(year, 11, 1);
    while (novDstEnd.weekday != DateTime.sunday) {
      novDstEnd = novDstEnd.add(const Duration(days: 1));
    }
    // Change happens at 2AM local. 2AM EDT is 6AM UTC.
    novDstEnd = novDstEnd.add(const Duration(hours: 6));

    return utcDate.isAfter(marchDstStart) && utcDate.isBefore(novDstEnd);
  }
}

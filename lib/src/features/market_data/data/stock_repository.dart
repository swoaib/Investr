import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../domain/stock.dart';
import '../domain/price_point.dart';
import '../domain/earnings_point.dart';
import '../../valuation/domain/dcf_data.dart';
import '../../valuation/domain/advanced_dcf_data.dart';
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
          double changePercent =
              (result['changesPercentage'] as num?)?.toDouble() ?? 0.0;

          if (changePercent == 0.0 && previousClose != 0.0) {
            changePercent = (change / previousClose) * 100;
          }

          return Stock(
            symbol: result['symbol'],
            companyName: name ?? result['name'] ?? result['symbol'],
            price: price,
            change: change,
            changePercent: changePercent,
            previousClose: previousClose,
            marketCap: (result['marketCap'] as num?)?.toDouble(),
            high52Week: (result['yearHigh'] as num?)?.toDouble(),
            low52Week: (result['yearLow'] as num?)?.toDouble(),
            peRatio: (result['pe'] as num?)?.toDouble(),
            earningsPerShare: (result['eps'] as num?)?.toDouble(),
            exchange: result['exchange'],
            // Quote sometimes has currency, if not null use it
            currency: result['currency'],
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
  /// Updated to use 'stable/profile' as v3 is legacy/restricted.
  Future<Stock> getStockDetails(Stock stock) async {
    try {
      // Endpoint: /stable/profile?symbol={symbol}
      final url = Uri.parse(
        '$_baseUrl/stable/profile?symbol=${stock.symbol}&apikey=$_apiKey',
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
            country: result['country'],
            exchange: result['exchangeShortName'] ?? result['exchange'],
            currency: result['currency'],
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching details for ${stock.symbol}: $e');
    }
    return stock;
  }

  /// Fetches Key Metrics TTM (PE, DivYield, EPS)
  /// Uses 'stable/ratios-ttm' only as it contains all required fields.
  Future<Stock> getKeyMetrics(Stock stock) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/stable/ratios-ttm?symbol=${stock.symbol}&apikey=$_apiKey',
      );

      final response = await http.get(url);
      Map<String, dynamic> ratios = {};

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          ratios = jsonResponse[0];
        }
      }

      final pe = (ratios['priceToEarningsRatioTTM'] as num?)?.toDouble();
      final eps = (ratios['netIncomePerShareTTM'] as num?)?.toDouble();

      // FMP Ratios sometimes uses different keys for yield
      final double? divYieldRaw =
          (ratios['dividendYieldTTM'] as num?)?.toDouble() ??
          (ratios['dividendYielTTM'] as num?)?.toDouble();

      double? divYieldPercent;
      if (divYieldRaw != null) {
        divYieldPercent = divYieldRaw * 100;
      }

      return stock.copyWith(
        peRatio: pe,
        dividendYield: divYieldPercent,
        earningsPerShare: eps,
      );
    } catch (e) {
      if (kDebugMode) print('Error fetching metrics for ${stock.symbol}: $e');
    }
    return stock;
  }

  Future<Stock> getQuote(Stock stock) async {
    // Just reuse getStock for now.
    final updated = await getStock(stock.symbol, name: stock.companyName);
    return updated ?? stock;
  }

  /// Fetches historical earnings (EPS) and Revenue for the Earnings chart.
  /// Uses 'stable/income-statement'.
  Future<List<EarningsPoint>> getEarningsHistory(
    String symbol, {
    String frequency = 'quarterly',
  }) async {
    try {
      final periodParam = frequency == 'quarterly' ? '&period=quarter' : '';
      // Fetch last 12 periods (3 years quarterly, or 12 years annual)
      // Note: "stable" endpoint requires 'symbol' as a query parameter, unlike v3 which uses path.
      final url = Uri.parse(
        '$_baseUrl/stable/income-statement?symbol=$symbol&apikey=$_apiKey$periodParam&limit=12',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        // FMP returns Descending (Newest first). We reverse for Chart (Oldest first).
        return data
            .map<EarningsPoint>((item) {
              final dateStr = item['date'] as String;
              final date = DateTime.tryParse(dateStr) ?? DateTime.now();

              // Format period label
              String period = date.year.toString();
              if (frequency == 'quarterly') {
                final month = date.month;
                final quarter = (month / 3).ceil();
                period = 'Q$quarter ${date.year.toString().substring(2)}';
              }

              return EarningsPoint(
                period: period,
                eps: (item['eps'] as num?)?.toDouble() ?? 0.0,
                revenue: (item['revenue'] as num?)?.toDouble() ?? 0.0,
                netIncome: (item['netIncome'] as num?)?.toDouble() ?? 0.0,
                grossProfit: (item['grossProfit'] as num?)?.toDouble() ?? 0.0,
                operatingIncome:
                    (item['operatingIncome'] as num?)?.toDouble() ?? 0.0,
              );
            })
            .toList()
            .reversed
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching earnings for $symbol: $e');
    }
    return [];
  }

  /// Fetches historical data (Daily Bars).
  /// Updated to use EOD Light endpoint for compatibility.
  Future<List<PricePoint>> getStockHistory(String symbol) async {
    try {
      // 1-Year implied default for the 'history' field used by 1Y/All/Custom logic,
      // but we should fetch as much as possible or at least enough for 'All' if manageable,
      // or default to 5 years.
      // EOD Light returns *all* available data by default if no date component is simpler,
      // or we can just fetch it all.
      // Endpoint: /stable/historical-price-eod/light?symbol={symbol}
      // This returns full history.

      final url = Uri.parse(
        '$_baseUrl/stable/historical-price-eod/light?symbol=$symbol&apikey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          final points = <PricePoint>[];
          for (var item in jsonResponse) {
            if (item is Map) {
              final dateStr = item['date'] as String?;
              final price =
                  (item['price'] as num?)?.toDouble() ??
                  (item['close'] as num?)?.toDouble();

              if (dateStr != null && price != null) {
                points.add(
                  PricePoint(date: DateTime.parse(dateStr), price: price),
                );
              }
            }
          }
          // FMP returns newest first. 1Y/All logic expects chronological?
          // The previous code did .reversed.toList().
          // Yes, UI usually expects chronological (Ascending).
          return points.reversed.toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching history for $symbol: $e');
    }
    return [];
  }

  Future<List<PricePoint>> getIntradayHistory(String symbol) async {
    try {
      // Use 5-minute data for '1D' view (Best Resolution: ~78 points/day)
      final fullHistory = await _getStockHistory5Min(symbol);

      if (fullHistory.isNotEmpty) {
        // Filter for the *latest* available trading day
        final lastPoint = fullHistory.last;
        final lastDate = lastPoint.date;

        return fullHistory
            .where(
              (p) =>
                  p.date.year == lastDate.year &&
                  p.date.month == lastDate.month &&
                  p.date.day == lastDate.day,
            )
            .toList();
      }

      // Fallback: If 5-min fails/empty, try 1-hour
      final hourHistory = await _getStockHistory1Hour(symbol);
      if (hourHistory.isNotEmpty) {
        final lastDate =
            hourHistory.last.date; // Corrected to use hourHistory.last
        return hourHistory
            .where(
              (p) =>
                  p.date.year == lastDate.year &&
                  p.date.month == lastDate.month &&
                  p.date.day == lastDate.day,
            )
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) print('Error fetching intraday history for $symbol: $e');
      return [];
    }
  }

  // New 5-Minute Endpoint Helper
  Future<List<PricePoint>> _getStockHistory5Min(String symbol) async {
    try {
      // Metric: 5min (~78 bars per day)
      // Endpoint: /stable/historical-chart/5min?symbol={symbol}
      final url = Uri.parse(
        '$_baseUrl/stable/historical-chart/5min?symbol=$symbol&apikey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          final points = <PricePoint>[];
          for (var item in jsonResponse) {
            if (item is Map) {
              final dateStr = item['date'] as String?;
              final price =
                  (item['close'] as num?)?.toDouble() ??
                  (item['price'] as num?)?.toDouble();

              if (dateStr != null && price != null) {
                points.add(
                  PricePoint(date: DateTime.parse(dateStr), price: price),
                );
              }
            }
          }
          // FMP returns newest first. Reverse to Ascending.
          return points.reversed.toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching 5min history for $symbol: $e');
    }
    return [];
  }

  // New 1-Hour Endpoint Helper
  Future<List<PricePoint>> _getStockHistory1Hour(String symbol) async {
    try {
      // Metric: 1hour (~7 bars per day)
      // Query param format is required for 'stable' endpoint:
      // /stable/historical-chart/1hour?symbol={symbol}
      final url = Uri.parse(
        '$_baseUrl/stable/historical-chart/1hour?symbol=$symbol&apikey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          final points = <PricePoint>[];
          for (var item in jsonResponse) {
            if (item is Map) {
              final dateStr = item['date'] as String?;
              final price =
                  (item['close'] as num?)?.toDouble() ??
                  (item['price'] as num?)?.toDouble();

              if (dateStr != null && price != null) {
                points.add(
                  PricePoint(date: DateTime.parse(dateStr), price: price),
                );
              }
            }
          }
          // FMP returns newest first. Reverse to Ascending.
          return points.reversed.toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching 1hour history for $symbol: $e');
    }
    return [];
  }

  // New 15-Minute Endpoint Helper
  Future<List<PricePoint>> _getStockHistory15Min(String symbol) async {
    try {
      // Metric: 15min (~26 bars per day)
      // Endpoint: /stable/historical-chart/15min?symbol={symbol}
      final url = Uri.parse(
        '$_baseUrl/stable/historical-chart/15min?symbol=$symbol&apikey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          final points = <PricePoint>[];
          for (var item in jsonResponse) {
            if (item is Map) {
              final dateStr = item['date'] as String?;
              final price =
                  (item['close'] as num?)?.toDouble() ??
                  (item['price'] as num?)?.toDouble();

              if (dateStr != null && price != null) {
                points.add(
                  PricePoint(date: DateTime.parse(dateStr), price: price),
                );
              }
            }
          }
          // FMP returns newest first. Reverse to Ascending.
          return points.reversed.toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching 15min history for $symbol: $e');
    }
    return [];
  }

  Future<List<PricePoint>> getWeeklyHistory(String symbol) async {
    try {
      // Use 15-minute data for better granularity (approx 180 points for a week)
      final fullHistory = await _getStockHistory15Min(symbol);
      if (fullHistory.isEmpty) {
        // Fallback to 1-hour if 15min fails
        final hourHistory = await _getStockHistory1Hour(symbol);
        if (hourHistory.isEmpty) {
          return _getWeeklyHistoryDaily(symbol);
        }
        fullHistory.addAll(hourHistory);
      }

      // Filter for last 7 days (True 1 Week view)
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 7));
      return fullHistory.where((p) => p.date.isAfter(cutoff)).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching weekly history for $symbol: $e');
      return [];
    }
  }

  Future<List<PricePoint>> getMonthlyHistory(String symbol) async {
    try {
      // Use 1-hour data for best granularity (approx 200+ points)
      final fullHistory = await _getStockHistory1Hour(symbol);
      if (fullHistory.isEmpty) {
        // Fallback to daily if 1hour fails
        return _getMonthlyHistoryDaily(symbol);
      }

      // Filter for last 30 days (True 1 Month view)
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 30));
      return fullHistory.where((p) => p.date.isAfter(cutoff)).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching monthly history for $symbol: $e');
      return [];
    }
  }

  // Backup methods using Daily data if 4hour returns empty/fails
  Future<List<PricePoint>> _getWeeklyHistoryDaily(String symbol) async {
    final fullHistory = await getStockHistory(symbol);
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7));
    return fullHistory.where((p) => p.date.isAfter(cutoff)).toList();
  }

  Future<List<PricePoint>> _getMonthlyHistoryDaily(String symbol) async {
    final fullHistory = await getStockHistory(symbol);
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 30));
    return fullHistory.where((p) => p.date.isAfter(cutoff)).toList();
  }

  /// Searches for a stock ticker.
  /// Searches for a stock ticker by symbol or company name.
  Future<List<({String symbol, String name})>> searchTicker(
    String query,
  ) async {
    try {
      final symbolUrl = Uri.parse(
        '$_baseUrl/stable/search-symbol?query=$query&limit=10&apikey=$_apiKey',
      );
      final nameUrl = Uri.parse(
        '$_baseUrl/stable/search-name?query=$query&limit=10&apikey=$_apiKey',
      );

      final results = await Future.wait([
        http.get(symbolUrl),
        http.get(nameUrl),
      ]);

      final Map<String, ({String symbol, String name})> combinedResults = {};

      // Helper to parse and add
      void parseAndAdd(http.Response response) {
        if (response.statusCode == 200) {
          try {
            final List<dynamic> data = json.decode(response.body);
            for (var item in data) {
              final sym = item['symbol'] as String;
              final name = item['name'] as String;
              // Prefer symbol match order, but map handles dedupe
              if (!combinedResults.containsKey(sym)) {
                combinedResults[sym] = (symbol: sym, name: name);
              }
            }
          } catch (_) {}
        }
      }

      // Process Symbol matches first (higher priority)
      parseAndAdd(results[0]); // Symbol Search
      // Process Name matches second
      parseAndAdd(results[1]); // Name Search

      return combinedResults.values.toList();
    } catch (e) {
      if (kDebugMode) print('API Search failed: $e');
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

  /// Fetches advanced DCF data including WACC, growth rate, etc.
  /// parameters are typically percentages (e.g. 9.5 for 9.5%)
  Future<AdvancedDCFData?> getAdvancedDCF(
    String symbol, {
    double? wacc,
    double? taxRate,
    double? riskFreeRate,
    double? longTermGrowthRate,
    double? beta,
  }) async {
    try {
      var query = 'symbol=$symbol&apikey=$_apiKey';
      if (wacc != null) query += '&wacc=$wacc';
      if (taxRate != null) query += '&taxRate=$taxRate';
      if (riskFreeRate != null) query += '&riskFreeRate=$riskFreeRate';
      if (longTermGrowthRate != null) {
        query += '&longTermGrowthRate=$longTermGrowthRate';
      }
      if (beta != null) query += '&beta=$beta';

      final url = Uri.parse(
        '$_baseUrl/stable/custom-discounted-cash-flow?$query',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return AdvancedDCFData.fromJson(data);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching Advanced DCF for $symbol: $e');
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

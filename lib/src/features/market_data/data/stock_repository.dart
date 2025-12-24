import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../domain/stock.dart';
import '../domain/price_point.dart';
import '../domain/earnings_point.dart';
import '../../valuation/domain/dcf_data.dart';

class StockRepository {
  final String _apiKey = 'gWdDRuo8TM3Mmy5cXuuwxbFuzpLpuRn1';
  String get apiKey => _apiKey;
  final String _baseUrl = 'https://api.polygon.io';

  // Hardcoded list of popular stocks for the dashboard to simulate a "Watchlist"
  static const String _watchlistKey = 'watchlist_v2';

  // Default stocks for new users
  final Map<String, String> _defaultWatchlist = {
    'AAPL': 'Apple Inc.',
    'GOOGL': 'Alphabet Inc.',
    'TSLA': 'Tesla Inc.',
    'TM': 'Toyota Motor Corp.',
    'MSFT': 'Microsoft Corp.',
    'AMZN': 'Amazon.com Inc.',
    'NVDA': 'Nvidia Corp.',
  };

  /// Fetches current data for the watchlist.
  /// Uses "Grouped Daily" endpoint to fetch all data in 1 API call to avoid rate limits.
  Future<List<Stock>> getWatchlistStocks() async {
    List<Stock> stocks = [];
    try {
      final watchlistMap = await _loadWatchlistMap();
      if (watchlistMap.isEmpty) {
        return [];
      }

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
          // Create a lookup map from API results
          final Map<String, dynamic> resultsMap = {
            for (var item in results) item['T']: item,
          };

          // Iterate through our PRESERVED watchlist order
          for (var ticker in watchlistMap.keys) {
            final item = resultsMap[ticker];

            if (item != null) {
              // Found data for this watchlist item
              final double currentPrice = (item['c'] as num).toDouble();
              final double openPrice = (item['o'] as num).toDouble();
              final double change = currentPrice - openPrice;
              final double changePercent = (openPrice != 0)
                  ? (change / openPrice) * 100
                  : 0.0;

              stocks.add(
                Stock(
                  symbol: ticker,
                  companyName: watchlistMap[ticker]!,
                  price: currentPrice,
                  change: change,
                  changePercent: changePercent,
                ),
              );
            }
          }
        }
      } else {
        throw Exception('Failed to fetch group data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching watchlist: $e');
      rethrow;
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
        if (kDebugMode) {
          print('Failed to fetch stock $symbol: ${response.statusCode}');
        }
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

  /// Fetches historical earnings (EPS) and Revenue for the Earnings chart.
  Future<List<EarningsPoint>> getEarningsHistory(
    String symbol, {
    String frequency = 'quarterly',
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/vX/reference/financials?ticker=$symbol&limit=8&sort=filing_date&order=desc&timeframe=$frequency&apiKey=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null) {
          final List<EarningsPoint> points = [];
          for (var report in results) {
            final period = report['fiscal_period'] as String? ?? '';
            final year = report['fiscal_year'] as String? ?? '';

            String label;
            if (frequency == 'annual') {
              label = year;
            } else {
              // Construct label like "Q3 23"
              final shortYear = year.length > 2 ? year.substring(2) : year;
              label = '$period $shortYear';
            }

            final financials = report['financials'];
            final incomeStatement = financials?['income_statement'];

            final epsNode = incomeStatement?['basic_earnings_per_share'];
            final revNode = incomeStatement?['revenues'];

            if (epsNode != null || revNode != null) {
              final epsVal = (epsNode?['value'] as num?)?.toDouble() ?? 0.0;
              final revVal = (revNode?['value'] as num?)?.toDouble() ?? 0.0;

              points.add(
                EarningsPoint(period: label, eps: epsVal, revenue: revVal),
              );
            }
          }
          return points.reversed.toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching earnings for $symbol: $e');
    }
    return [];
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
      // Using 5-minute intervals for more detailed graph
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/range/5/minute/$dateStr/$dateStr?adjusted=true&sort=asc&apiKey=$_apiKey',
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

  /// Fetches 30-minute data for the "1W" chart.
  Future<List<PricePoint>> getWeeklyHistory(String symbol) async {
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 7));
      final dateFormat = DateFormat('yyyy-MM-dd');

      // /v2/aggs/ticker/{ticker}/range/30/minute/{from}/{to}
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/range/30/minute/${dateFormat.format(from)}/${dateFormat.format(now)}?adjusted=true&sort=asc&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          return results
              .map((candle) {
                final date = DateTime.fromMillisecondsSinceEpoch(candle['t']);
                final close = (candle['c'] as num).toDouble();
                return PricePoint(date: date, price: close);
              })
              .where(
                (p) =>
                    p.date.weekday != DateTime.saturday &&
                    p.date.weekday != DateTime.sunday,
              )
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching weekly for $symbol: $e');
    }
    return [];
  }

  /// Fetches hourly data for the "1M" chart.
  Future<List<PricePoint>> getMonthlyHistory(String symbol) async {
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 30));
      final dateFormat = DateFormat('yyyy-MM-dd');

      // /v2/aggs/ticker/{ticker}/range/1/hour/{from}/{to}
      final url = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/range/1/hour/${dateFormat.format(from)}/${dateFormat.format(now)}?adjusted=true&sort=asc&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          return results
              .map((candle) {
                final date = DateTime.fromMillisecondsSinceEpoch(candle['t']);
                final close = (candle['c'] as num).toDouble();
                return PricePoint(date: date, price: close);
              })
              .where(
                (p) =>
                    p.date.weekday != DateTime.saturday &&
                    p.date.weekday != DateTime.sunday,
              )
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching monthly for $symbol: $e');
    }
    return [];
  }

  /// Searches for a stock ticker by symbol or name.
  /// Returns a list of matching ticker symbols and names.
  Future<List<({String symbol, String name})>> searchTicker(
    String query,
  ) async {
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

  // Encryption/Persistence Helpers

  Future<Map<String, String>> _loadWatchlistMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_watchlistKey);

    if (jsonString == null) {
      // Seed with default
      await _saveWatchlistMap(_defaultWatchlist);
      return _defaultWatchlist;
    }

    try {
      final List<dynamic> list = json.decode(jsonString);
      return {for (var item in list) item['symbol']: item['name']};
    } catch (e) {
      // Fallback if corrupted
      return _defaultWatchlist;
    }
  }

  Future<void> _saveWatchlistMap(Map<String, String> watchlist) async {
    final prefs = await SharedPreferences.getInstance();
    final list = watchlist.entries
        .map((e) => {'symbol': e.key, 'name': e.value})
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

  /// Fetches data required for DCF calculation.
  Future<DCFData?> getDCFData(String symbol) async {
    try {
      // 1. Get Current Price
      final priceUrl = Uri.parse(
        '$_baseUrl/v2/aggs/ticker/$symbol/prev?adjusted=true&apiKey=$_apiKey',
      );
      final priceResponse = await http.get(priceUrl);
      double price = 0.0;
      if (priceResponse.statusCode == 200) {
        final data = json.decode(priceResponse.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          price = (results.first['c'] as num).toDouble();
        }
      }

      // 2. Get Financials
      final financialsUrl = Uri.parse(
        '$_baseUrl/vX/reference/financials?ticker=$symbol&limit=1&apiKey=$_apiKey',
      );
      final finResponse = await http.get(financialsUrl);

      if (finResponse.statusCode == 200) {
        final data = json.decode(finResponse.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final financials = results.first['financials'];
          final income = financials?['income_statement'];
          final balance = financials?['balance_sheet'];
          final cashFlow = financials?['cash_flow_statement'];

          // Shares Outstanding (Weighted Average)
          final sharesNode =
              income?['weighted_average_shares_outstanding_diluted'] ??
              income?['basic_average_shares'];
          final double shares = (sharesNode?['value'] as num?)?.toDouble() ?? 0;

          // Free Cash Flow = Operating Cash Flow - CapEx
          // Note: Polygon vX (Standardized) often lumps CapEx into 'net_cash_flow_from_investing_activities'.
          // Valid keys verified: 'net_cash_flow_from_operating_activities', 'net_cash_flow_from_investing_activities'.

          final double operatingCashFlow =
              (cashFlow?['net_cash_flow_from_operating_activities']?['value']
                      as num?)
                  ?.toDouble() ??
              0;

          // We use investing cash flow as a proxy for CapEx since specific 'capital_expenditures' key is missing for some symbols (e.g. AAPL).
          // Investing flow is usually negative (outflow).
          final double investingCashFlow =
              (cashFlow?['net_cash_flow_from_investing_activities']?['value']
                      as num?)
                  ?.toDouble() ??
              0;

          final double freeCashFlow = operatingCashFlow + investingCashFlow;

          // Net Debt = Total Debt - Cash
          // Valid keys verified: 'long_term_debt'. 'total_debt' and 'short_term_debt' often missing.
          // 'cash_and_cash_equivalents' also often missing, making Net Debt calc difficult.

          double totalDebt =
              (balance?['long_term_debt']?['value'] as num?)?.toDouble() ?? 0;
          if (balance?['debt'] != null) {
            totalDebt =
                (balance?['debt']['value'] as num?)?.toDouble() ?? totalDebt;
          }

          final double cash =
              (balance?['cash_and_cash_equivalents']?['value'] as num?)
                  ?.toDouble() ??
              0;

          // If short term investments key exists (rare), we use it.
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
    } catch (e) {
      if (kDebugMode) print('Error fetching DCF data for $symbol: $e');
    }
    return null;
  }
}

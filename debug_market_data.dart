import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<void> main() async {
  const apiKey = 'gWdDRuo8TM3Mmy5cXuuwxbFuzpLpuRn1';
  const baseUrl = 'https://api.polygon.io';

  // 1. Simulate Default Watchlist
  final Map<String, String> watchlistMap = {
    'AAPL': 'Apple Inc.',
    'GOOGL': 'Alphabet Inc.',
    'TSLA': 'Tesla Inc.',
    'TM': 'Toyota Motor Corp.',
    'MSFT': 'Microsoft Corp.',
    'AMZN': 'Amazon.com Inc.',
    'NVDA': 'Nvidia Corp.',
  };
  print('Watchlist: ${watchlistMap.keys.toList()}');

  // 2. Initial Date (Simulate _getLastTradingDay for today/yesterday)
  // We'll just ask AAPL/prev to be proper
  DateTime date;
  try {
    final prevUrl = Uri.parse(
      '$baseUrl/v2/aggs/ticker/AAPL/prev?adjusted=true&apiKey=$apiKey',
    );
    final prevResp = await http.get(prevUrl);
    final prevData = json.decode(prevResp.body);
    final ts = prevData['results'][0]['t'] as int;
    date = DateTime.fromMillisecondsSinceEpoch(ts);
    print('Initial Date from API: $date');
  } catch (e) {
    print('Error getting initial date: $e');
    return;
  }

  // 3. Retry Loop Logic
  List<dynamic> storedStocks = [];

  for (int i = 0; i < 5; i++) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    print('\nAttempt $i: Fetching for $dateStr...');

    final url = Uri.parse(
      '$baseUrl/v2/aggs/grouped/locale/us/market/stocks/$dateStr?adjusted=true&apiKey=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>?;

      if (results != null && results.isNotEmpty) {
        print('Success! Found ${results.length} results.');

        // Parsing Logic
        final Map<String, dynamic> resultsMap = {
          for (var item in results) item['T']: item,
        };

        for (var ticker in watchlistMap.keys) {
          final item = resultsMap[ticker];
          if (item != null) {
            print('  Matched $ticker: ${item['c']}');
            storedStocks.add(item);
          } else {
            print('  FAILED to match $ticker');
          }
        }

        if (storedStocks.isNotEmpty) {
          print('\nTotal matched stocks: ${storedStocks.length}');
          return; // EXIT SUCCESS
        } else {
          print('Results found but NO watchlist items matched?');
          return;
        }
      } else {
        print('No results (Holiday?). Going back 1 day.');
        date = date.subtract(const Duration(days: 1));
        while (date.weekday == 6 || date.weekday == 7) {
          date = date.subtract(const Duration(days: 1));
        }
      }
    } else {
      print('API Error: ${response.statusCode}');
      break;
    }
  }
}

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> main() async {
  // Load .env manually since we are in a script
  try {
    final envFile = File('.env');
    final envContent = await envFile.readAsString();
    final Map<String, String> env = {};
    for (var line in envContent.split('\n')) {
      if (line.contains('=')) {
        final parts = line.split('=');
        env[parts[0].trim()] = parts[1].trim();
      }
    }
    dotenv.testLoad(fileInput: envContent);
  } catch (e) {
    print('Error loading .env: $e');
    return;
  }

  final apiKey = dotenv.env['FMP_API_KEY'];

  // 0. Test Stock List (Basic Availability)
  try {
    print('\n--- Testing Stock List ---');
    final url = Uri.parse('$baseUrl/stock/list?limit=5&apikey=$apiKey');
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: stock/list');
  } catch (e) {
    print(e);
  }

  // 1. Test Multiple Endpoints to find what works
  print('\n--- Testing Endpoints ---');

  // A. Quote Short (Real-time price)
  try {
    print('Testing /quote-short/AAPL ...');
    final url = Uri.parse('$baseUrl/quote-short/AAPL?apikey=$apiKey');
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: quote-short');
  } catch (e) {
    print(e);
  }

  // B. Company Profile
  try {
    print('\nTesting /profile/AAPL ...');
    final url = Uri.parse('$baseUrl/profile/AAPL?apikey=$apiKey');
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: profile');
  } catch (e) {
    print(e);
  }

  // C. Historical Price Daily
  try {
    print('\nTesting /historical-price-full/AAPL ...');
    final url = Uri.parse(
      '$baseUrl/historical-price-full/AAPL?timeseries=1&apikey=$apiKey',
    );
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: historical-price-full');
  } catch (e) {
    print(e);
  }

  // D. v4 Profile
  try {
    print('\nTesting v4/profile/AAPL ...');
    final url = Uri.parse(
      'https://financialmodelingprep.com/api/v4/profile/AAPL?apikey=$apiKey',
    );
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: v4/profile');
  } catch (e) {
    print(e);
  }

  // G. STABLE Endpoints (User confirmed working)
  final stableUrl = 'https://financialmodelingprep.com/stable';

  // Search
  try {
    print('\nTesting STABLE Search ...');
    final url = Uri.parse(
      '$stableUrl/search?query=AAPL&limit=5&apikey=$apiKey',
    );
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: stable/search');
  } catch (e) {
    print(e);
  }

  // Quote
  try {
    print('\nTesting STABLE Quote ...');
    final url = Uri.parse('$stableUrl/quote?symbol=AAPL&apikey=$apiKey');
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: stable/quote');
  } catch (e) {
    print(e);
  }

  // Historical Variations (Verified from Search)
  print('\n--- Testing VERIFIED STABLE History ---');

  // Daily Full History
  try {
    print('Testing stable/historical-price-eod/full?symbol=AAPL ...');
    final url = Uri.parse(
      '$stableUrl/historical-price-eod/full?symbol=AAPL&apikey=$apiKey',
    );
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: historical-price-eod');
  } catch (e) {
    print(e);
  }

  // Intraday
  try {
    print('\nTesting stable/historical-chart/5min?symbol=AAPL ...');
    final url = Uri.parse(
      '$stableUrl/historical-chart/5min?symbol=AAPL&apikey=$apiKey',
    );
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: historical-chart/5min');
  } catch (e) {
    print(e);
  }

  // Indices Check (S&P 500)
  try {
    print('\nTesting stable/historical-price-eod/light?symbol=^GSPC ...');
    final url = Uri.parse(
      '$stableUrl/historical-price-eod/light?symbol=^GSPC&apikey=$apiKey',
    );
    final response = await http.get(url);
    print(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) print('SUCCESS: Index ^GSPC');
  } catch (e) {
    print(e);
  }

  // 2. Search for Indices to find correct symbols
  final queries = ['S&P 500', 'Nikkei', 'Oslo', 'Nasdaq 100'];

  for (var q in queries) {
    print('\n--- Searching for "$q" ---');
    try {
      // Searching specifically for indices if possible, general search otherwise
      final url = Uri.parse('$baseUrl/search?query=$q&limit=10&apikey=$apiKey');
      final response = await http.get(url);
      print(
        '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        for (var item in data) {
          print(
            '${item['symbol']} (${item['stockExchange']}) - ${item['name']}',
          );
        }
      }
    } catch (e) {
      print('Error searching $q: $e');
    }
  }
}

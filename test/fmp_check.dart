import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

const baseUrl = 'https://financialmodelingprep.com/api/v3';

Future<void> main() async {
  // Load .env manually since we are in a script
  final Map<String, String> env = {};
  try {
    final envFile = File('.env');
    final envContent = await envFile.readAsString();
    for (var line in envContent.split('\n')) {
      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          env[parts[0].trim()] = parts.sublist(1).join('=').trim();
        }
      }
    }
  } catch (e) {
    debugPrint('Error loading .env: $e');
    return;
  }

  final apiKey = env['FMP_API_KEY'];

  // 0. Test Stock List (Basic Availability)
  try {
    debugPrint('\n--- Testing Stock List ---');
    final url = Uri.parse('$baseUrl/stock/list?limit=5&apikey=$apiKey');
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) debugPrint('SUCCESS: stock/list');
  } catch (e) {
    debugPrint(e.toString());
  }

  // 1. Test Multiple Endpoints to find what works
  debugPrint('\n--- Testing Endpoints ---');

  // A. Quote Short (Real-time price)
  try {
    debugPrint('Testing /quote-short/AAPL ...');
    final url = Uri.parse('$baseUrl/quote-short/AAPL?apikey=$apiKey');
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
    );
    if (response.statusCode == 200) debugPrint('SUCCESS: quote-short');
  } catch (e) {
    debugPrint(e.toString());
  }

  // B. Company Profile
  try {
    debugPrint('\nTesting /profile/AAPL ...');
    final url = Uri.parse('$baseUrl/profile/AAPL?apikey=$apiKey');
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
    );
    if (response.statusCode == 200) debugPrint('SUCCESS: profile');
  } catch (e) {
    debugPrint(e.toString());
  }

  // C. Historical Price Daily
  try {
    debugPrint('\nTesting /historical-price-full/AAPL ...');
    final url = Uri.parse(
      '$baseUrl/historical-price-full/AAPL?timeseries=1&apikey=$apiKey',
    );
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
    );
    if (response.statusCode == 200) {
      debugPrint('SUCCESS: historical-price-full');
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  // D. v4 Profile
  try {
    debugPrint('\nTesting v4/profile/AAPL ...');
    final url = Uri.parse(
      'https://financialmodelingprep.com/api/v4/profile/AAPL?apikey=$apiKey',
    );
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
    );
    if (response.statusCode == 200) debugPrint('SUCCESS: v4/profile');
  } catch (e) {
    debugPrint(e.toString());
  }

  // G. STABLE Endpoints (User confirmed working)
  final stableUrl = 'https://financialmodelingprep.com/stable';

  // Search
  try {
    debugPrint('\nTesting STABLE Search ...');
    final url = Uri.parse(
      '$stableUrl/search?query=AAPL&limit=5&apikey=$apiKey',
    );
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) debugPrint('SUCCESS: stable/search');
  } catch (e) {
    debugPrint(e.toString());
  }

  // Quote
  try {
    debugPrint('\nTesting STABLE Quote ...');
    final url = Uri.parse('$stableUrl/quote?symbol=AAPL&apikey=$apiKey');
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) debugPrint('SUCCESS: stable/quote');
  } catch (e) {
    debugPrint(e.toString());
  }

  // Currency Exchange Rate
  try {
    debugPrint('\nTesting Exchange Rate (USD -> EUR) ...');
    // FMP pairs: USDEUR
    final url = Uri.parse('$stableUrl/quote?symbol=USDEUR&apikey=$apiKey');
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) {
      debugPrint('SUCCESS: Currency Exchange Rate');
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  // Historical Variations (Verified from Search)
  debugPrint('\n--- Testing VERIFIED STABLE History ---');

  // Daily Full History
  try {
    debugPrint('Testing stable/historical-price-eod/full?symbol=AAPL ...');
    final url = Uri.parse(
      '$stableUrl/historical-price-eod/full?symbol=AAPL&apikey=$apiKey',
    );
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) debugPrint('SUCCESS: historical-price-eod');
  } catch (e) {
    debugPrint(e.toString());
  }

  // Intraday
  try {
    debugPrint('\nTesting stable/historical-chart/5min?symbol=AAPL ...');
    final url = Uri.parse(
      '$stableUrl/historical-chart/5min?symbol=AAPL&apikey=$apiKey',
    );
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) {
      debugPrint('SUCCESS: historical-chart/5min');
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  // Indices Check (S&P 500)
  try {
    debugPrint('\nTesting stable/historical-price-eod/light?symbol=^GSPC ...');
    final url = Uri.parse(
      '$stableUrl/historical-price-eod/light?symbol=^GSPC&apikey=$apiKey',
    );
    final response = await http.get(url);
    debugPrint(
      '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
    );
    if (response.statusCode == 200) {
      debugPrint('SUCCESS: Index ^GSPC');
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  // 2. Search for Indices to find correct symbols
  final queries = ['S&P 500', 'Nikkei', 'Oslo', 'Nasdaq 100'];

  for (var q in queries) {
    debugPrint('\n--- Searching for "$q" ---');
    try {
      // Searching specifically for indices if possible, general search otherwise
      final url = Uri.parse('$baseUrl/search?query=$q&limit=10&apikey=$apiKey');
      final response = await http.get(url);
      debugPrint(
        '${response.statusCode}: ${response.body.length > 50 ? response.body.substring(0, 50) : response.body}',
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        for (var item in data) {
          debugPrint(
            '${item['symbol']} (${item['stockExchange']}) - ${item['name']}',
          );
        }
      }
    } catch (e) {
      debugPrint('Error searching $q: $e');
    }
  }
}

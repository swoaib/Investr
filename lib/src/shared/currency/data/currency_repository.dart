import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CurrencyRepository {
  late final String _apiKey;
  final String _baseUrl = 'https://financialmodelingprep.com';

  CurrencyRepository() {
    _apiKey = dotenv.env['FMP_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      if (kDebugMode) {
        print('WARNING: FMP_API_KEY is missing in .env');
      }
    }
  }

  /// Fetches the current exchange rate between two currencies (e.g. USD -> EUR).
  Future<double?> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;
    try {
      // FMP uses direct concatenation for pairs: e.g. "EURUSD".
      // Example: USD -> EUR : symbol=USDEUR
      final symbol = '$from$to';
      final url = Uri.parse(
        '$_baseUrl/stable/quote?symbol=$symbol&apikey=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Quote endpoint returns 'price' which is the rate
          return (data[0]['price'] as num?)?.toDouble();
        }
      } else {
        if (kDebugMode) {
          print('FMP API HTTP Error ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching FX rate for $from$to: $e');
    }
    return null;
  }
}

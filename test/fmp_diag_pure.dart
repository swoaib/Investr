import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  debugPrint('--- FMP 402 DIAGNOSIS (PURE DART) ---');

  // 1. Load API Key manually from .env
  String? apiKey;
  try {
    final file = File('.env');
    if (await file.exists()) {
      final lines = await file.readAsLines();
      for (var line in lines) {
        if (line.startsWith('FMP_API_KEY=')) {
          apiKey = line.split('=')[1].trim();
        }
      }
    }
  } catch (e) {
    debugPrint('Error reading .env: $e');
  }

  if (apiKey == null || apiKey.isEmpty) {
    debugPrint('CRITICAL: Could not find FMP_API_KEY in .env');
    return;
  }

  debugPrint('API Key loaded: ${apiKey.substring(0, 4)}...');

  // 2. Test Endpoints
  // Case A: Single Stock Quote (Should work)
  await _check(
    'Stable Quote AAPL',
    'https://financialmodelingprep.com/stable/quote?symbol=AAPL&apikey=$apiKey',
  );

  // Case B: Single Index Quote (Suspect 402)
  await _check(
    'Stable Quote ^GSPC (Index)',
    'https://financialmodelingprep.com/stable/quote?symbol=^GSPC&apikey=$apiKey',
  );

  // Case C: Batch Stocks (Suspect 402)
  await _check(
    'Stable Batch AAPL,MSFT',
    'https://financialmodelingprep.com/stable/quote?symbol=AAPL,MSFT&apikey=$apiKey',
  );
}

Future<void> _check(String name, String url) async {
  debugPrint('\nChecking: $name');
  try {
    final response = await http.get(Uri.parse(url));
    debugPrint('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      debugPrint('Success. Data length: ${response.body.length}');
    } else {
      debugPrint('FAILED. Body: ${response.body}');
    }
  } catch (e) {
    debugPrint('Exception: $e');
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('--- FMP 402 DIAGNOSIS (PURE DART) ---');

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
    print('Error reading .env: $e');
  }

  if (apiKey == null || apiKey.isEmpty) {
    print('CRITICAL: Could not find FMP_API_KEY in .env');
    return;
  }

  print('API Key loaded: ${apiKey.substring(0, 4)}...');

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
  print('\nChecking: $name');
  try {
    final response = await http.get(Uri.parse(url));
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Success. Data length: ${response.body.length}');
    } else {
      print('FAILED. Body: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}

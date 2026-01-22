import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Load .env
  final Map<String, String> env = {};
  try {
    final envFile = File('.env');
    final envContent = await envFile.readAsString();
    for (var line in envContent.split('\n')) {
      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length >= 2)
          env[parts[0].trim()] = parts.sublist(1).join('=').trim();
      }
    }
  } catch (e) {
    print('Error loading .env: $e');
    return;
  }

  final apiKey = env['FMP_API_KEY'];
  final baseUrl = 'https://financialmodelingprep.com/stable';

  // Check Nikkei 225 (Tokyo)
  await checkSymbol(baseUrl, apiKey!, '^N225');

  // Check AAPL (US) for comparison
  await checkSymbol(baseUrl, apiKey, 'AAPL');
}

Future<void> checkSymbol(String baseUrl, String apiKey, String symbol) async {
  print('\n--- Checking $symbol ---');
  final url = Uri.parse(
    '$baseUrl/historical-chart/5min?symbol=$symbol&apikey=$apiKey',
  );
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        // Print first and last
        print('First (Latest) Point: ${data.first}');
        print('Last (Earliest) Point: ${data.last}');

        // Take a sample from the middle
        if (data.length > 10) {
          print('Sample Point: ${data[10]}');
        }
      } else {
        print('No data found.');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}

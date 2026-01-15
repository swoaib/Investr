import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = 'A0bohVBVJJECcrcUlt2SKlBlOLpGoALj';
  const symbol = 'AAPL';

  print('Testing Intraday Endpoints...');

  // List of intervals to test
  final intervals = ['1min', '5min', '15min', '30min'];

  for (final interval in intervals) {
    print('\n--- Testing $interval ---');
    try {
      final url = Uri.parse(
        'https://financialmodelingprep.com/stable/historical-chart/$interval?symbol=$symbol&apikey=$apiKey',
      );

      print('Fetching: $url');
      final response = await http.get(url);

      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Items received: ${data.length}');

        if (data.isNotEmpty) {
          print('First: ${data.first['date']}');
          print('Last: ${data.last['date']}');
        }
      } else {
        print('Body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

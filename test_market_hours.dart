import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const apiKey = 'A0bohVBVJJECcrcUlt2SKlBlOLpGoALj'; // Dev key
  final url = Uri.parse(
    'https://financialmodelingprep.com/stable/is-the-market-open?apikey=$apiKey',
  );

  try {
    print('Fetching market status...');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Found ${data.length} exchanges.');

      // Print first few
      for (var i = 0; i < 5 && i < data.length; i++) {
        print(data[i]);
      }

      // Check specific exchanges if possible
      final nyse = data.firstWhere(
        (e) =>
            e['exchange'] == 'New York Stock Exchange' ||
            e['exchange'] == 'NYSE',
        orElse: () => null,
      );
      if (nyse != null) print('\nNYSE: $nyse');

      final london = data.firstWhere(
        (e) => e['exchange'].toString().contains('London'),
        orElse: () => null,
      );
      if (london != null) print('\nLSE: $london');
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}

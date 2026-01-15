import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const apiKey = 'A0bohVBVJJECcrcUlt2SKlBlOLpGoALj'; // From .env
  const symbol = 'AAPL';
  const baseUrl = 'https://financialmodelingprep.com';

  // 1. Calculate Dates
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 5));
  final toStr = now.toIso8601String().split('T')[0];
  final fromStr = from.toIso8601String().split('T')[0]; // "YYYY-MM-DD"

  print('Dates: From $fromStr to $toStr');

  // Try EOD Light (Basic Stock Chart API)
  final urlStr =
      '$baseUrl/stable/historical-price-eod/light?symbol=$symbol&apikey=$apiKey';
  final url = Uri.parse(urlStr);
  print('Fetching: $urlStr');

  try {
    final response = await http.get(url);
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Items received: ${data.length}');

      if (data.isNotEmpty) {
        // Mimic Repository Logic
        final points = <_Point>[];
        final limit = 30;
        var count = 0;

        for (var item in data) {
          if (count >= limit) break;
          // EOD Light returns "date" and "price" (not close)
          final dStr = item['date'] as String;
          final price =
              (item['price'] as num?)?.toDouble() ??
              (item['close'] as num?)?.toDouble() ??
              0.0;
          points.add(_Point(DateTime.parse(dStr), price));
          count++;
        }

        // Reverse
        final reversedPoints = points.reversed.toList();
        print(
          'Parsed ${reversedPoints.length} points (Reversed/Ascending). First: ${reversedPoints.first.date}, Last: ${reversedPoints.last.date}',
        );

        // Filter (now simpler)
        final filtered = filterForMarketHours(reversedPoints);
        print('Filtered Result (returned as-is): ${filtered.length} points');
      }
    } else {
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

class _Point {
  final DateTime date;
  final double price;
  _Point(this.date, this.price);
}

void checkPoint(_Point p) {
  final h = p.date.hour;
  final m = p.date.minute;
  bool valid = true;
  if (h < 9 || h > 16) valid = false;
  if (h == 9 && m < 30) valid = false;
  if (h == 16 && m > 0) valid = false;
  if (p.date.weekday >= 6) valid = false;

  print('Date: ${p.date} (Hour:$h, Min:$m) -> Valid? $valid');
}

List<_Point> filterForMarketHours(List<_Point> points) {
  if (points.isEmpty) return [];
  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
}

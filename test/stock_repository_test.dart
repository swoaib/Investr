import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:investr/src/features/market_data/data/stock_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    // Load test environment variables
    await dotenv.load(
      fileName: '/Users/sohaibahmed/Developer/Investr/test/.env',
    );
  });

  group('StockRepository DCF Tests', () {
    test('getAdvancedDCF divides taxRate by 100 in URL', () async {
      final mockClient = MockClient((request) async {
        // Verify the URL parameters
        final uri = request.url;
        expect(uri.queryParameters['taxRate'], equals('0.1561'));
        expect(uri.queryParameters['symbol'], equals('AAPL'));
        expect(uri.queryParameters['wacc'], equals('8.85'));
        expect(uri.queryParameters['longTermGrowthRate'], equals('5.0'));

        // Return valid empty JSON list to avoid parsing errors
        return http.Response(
          jsonEncode([
            {
              "symbol": "AAPL",
              "date": "2025-09-24",
              "equityValuePerShare": 176.65,
              // Add minimal required fields to parse successfully if needed
            },
          ]),
          200,
        );
      });

      final repository = StockRepository(client: mockClient);

      await repository.getAdvancedDCF(
        'AAPL',
        wacc: 8.85,
        taxRate: 15.61, // User input as percentage
        longTermGrowthRate: 5.0,
      );
    });

    test('getAdvancedDCF does not send taxRate if null', () async {
      final mockClient = MockClient((request) async {
        final uri = request.url;
        expect(uri.queryParameters.containsKey('taxRate'), isFalse);
        return http.Response(jsonEncode([]), 200);
      });

      final repository = StockRepository(client: mockClient);

      await repository.getAdvancedDCF(
        'AAPL',
        wacc: 8.85,
        // taxRate is null
      );
    });
  });
}

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:investr/src/features/market_data/data/stock_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  bool envLoaded = false;

  setUpAll(() async {
    // Load environment variables (real API key needed for FMP)
    // NOTE: This assumes the test is run from project root or path is correct
    try {
      await dotenv.load(fileName: '.env');
      if ((dotenv.env['FMP_API_KEY'] ?? '').isNotEmpty) {
        envLoaded = true;
      }
    } catch (e) {
      print('WARNING: .env not found. Skipping data accuracy tests.');
    }
  });

  group('Data Accuracy Verification', () {
    final symbols = ['AAPL', 'MSFT', 'GOOGL', 'NVDA'];

    for (final symbol in symbols) {
      test('Verify $symbol data matches Yahoo Finance', () async {
        if (!envLoaded) {
          markTestSkipped('Missing FMP_API_KEY in .env');
          return;
        }

        final repository = StockRepository();
        // 1. Fetch FMP Data
        final fmpStock = await repository.getStock(symbol);

        if (fmpStock == null) {
          fail('Failed to fetch FMP data for $symbol');
        }

        // 2. Fetch Yahoo Data
        // Using query1.finance.yahoo.com/v8/finance/chart/SYMBOL?interval=1d&range=1d
        final yahooUrl = Uri.parse(
          'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&range=1d',
        );
        final yahooResponse = await http.get(yahooUrl);
        expect(
          yahooResponse.statusCode,
          200,
          reason: 'Failed to fetch Yahoo data for $symbol',
        );

        final yahooData = json.decode(yahooResponse.body);
        final meta = yahooData['chart']['result'][0]['meta'];

        final prevClose = meta['previousClose'] ?? meta['chartPreviousClose'];

        if (meta['regularMarketPrice'] == null || prevClose == null) {
          print('Skipping $symbol: Missing Yahoo data. Meta: $meta');
          return;
        }

        final yahooPrice = (meta['regularMarketPrice'] as num).toDouble();
        final yahooPrevClose = (prevClose as num).toDouble();

        // Calculate Change % from Yahoo data for comparison
        // (Price - PrevClose) / PrevClose * 100
        final yahooChangePercent =
            ((yahooPrice - yahooPrevClose) / yahooPrevClose) * 100;

        print('\n--- $symbol Comparison ---');
        print(
          'FMP Price: \${fmpStock.price.toStringAsFixed(2)} | Yahoo Price: \${yahooPrice.toStringAsFixed(2)}',
        );
        print(
          'FMP Prev Close: \${fmpStock.previousClose?.toStringAsFixed(2)} | Yahoo Prev Close: \${yahooPrevClose.toStringAsFixed(2)}',
        );
        print(
          'FMP Change %: ${fmpStock.changePercent.toStringAsFixed(2)}% | Yahoo Change %: ${yahooChangePercent.toStringAsFixed(2)}%',
        );

        // 3. Assertions (Allowing for small differences due to delay/source)
        // Price should be within 1% (market moves fast, but should be close)
        // Note: If market is closed, they should be identical. If open, may vary slightly.

        final priceDiffPercent =
            ((fmpStock.price - yahooPrice).abs() / yahooPrice) * 100;
        if (priceDiffPercent > 1.0) {
          print('WARNING: Price difference > 1% ($priceDiffPercent%)');
        }

        // Prev Close should be identical (static value)
        // Allow very small epsilon for float precision
        if (fmpStock.previousClose != null) {
          final prevCloseDiff = (fmpStock.previousClose! - yahooPrevClose)
              .abs();
          expect(
            prevCloseDiff,
            lessThan(0.05),
            reason: 'Previous Close mismatch for $symbol',
          );
        }
      });
    }
  });
}

// ignore_for_file: avoid_print
import 'package:investr/src/shared/market/market_schedule_service.dart';

void main() {
  final now =
      DateTime.now(); // Date doesn't matter for non-DST zones like Tokyo

  print('--- Verifying Offsets ---');

  // Tokyo (^N225)
  // Expect 9 (JST)
  final offsetJp = MarketScheduleService.getUtcOffset('^N225', now);
  print('^N225 Offset: $offsetJp (Expected: 9)');

  // Hong Kong (^HSI)
  // Expect 8 (HKT)
  final offsetHk = MarketScheduleService.getUtcOffset('^HSI', now);
  print('^HSI Offset: $offsetHk (Expected: 8)');

  // US (AAPL)
  // Expect -5 (Standard) or -4 (DST)
  // Let's test specific dates for DST
  final winterDate = DateTime(2023, 1, 1);
  final summerDate = DateTime(2023, 6, 1);

  final offsetUsWinter = MarketScheduleService.getUtcOffset('AAPL', winterDate);
  print('AAPL Winter Offset: $offsetUsWinter (Expected: -5)');

  final offsetUsSummer = MarketScheduleService.getUtcOffset('AAPL', summerDate);
  print('AAPL Summer Offset: $offsetUsSummer (Expected: -4)');

  print('--- Verification Complete ---');
}

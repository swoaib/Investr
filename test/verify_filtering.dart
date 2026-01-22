import 'package:investr/src/shared/market/market_schedule_service.dart';

void main() {
  print('--- Verifying Filtering Logic ---');

  final symbol = '^N225';

  // Simulate a stored point.
  // Nikkei 9:00 AM JST.
  // Offset is +9.
  // Stored UTC = 9:00 - 9h = 00:00 UTC.
  final storedDate = DateTime.utc(2026, 1, 23, 0, 0, 0);

  print('Stored UTC Date: $storedDate');

  // Logic from StockRepository.filterForMarketHours
  final schedule = MarketScheduleService.getSchedule(symbol);

  final offset = MarketScheduleService.getUtcOffset(symbol, storedDate);
  final marketTime = storedDate.add(Duration(hours: offset));

  print('Converted Market Time: $marketTime');

  final mins = marketTime.hour * 60 + marketTime.minute;
  final startMins = schedule.startHour * 60 + schedule.startMinute;
  final endMins = schedule.endHour * 60 + schedule.endMinute;

  print('Mins: $mins');
  print('StartMins: $startMins');
  print('EndMins: $endMins');

  bool kept = mins >= startMins && mins <= endMins;

  // Check Lunch
  if (schedule.lunchStartHour != null) {
    final lunchStart =
        schedule.lunchStartHour! * 60 + (schedule.lunchStartMinute ?? 0);
    final lunchEnd =
        schedule.lunchEndHour! * 60 + (schedule.lunchEndMinute ?? 0);
    if (mins >= lunchStart && mins < lunchEnd) {
      print('Filtered by Lunch');
      kept = false;
    }
  }

  print('Kept: $kept');

  if (kept) {
    print('SUCCESS: Point was kept.');
  } else {
    print('FAILURE: Point was filtered out.');
  }
}

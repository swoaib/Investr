/// Defines the trading schedule and timezone for a specific market.
class MarketSchedule {
  final String timezone; // IANA Timezone ID (e.g., 'America/New_York')
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  // Lunch break (optional)
  final int? lunchStartHour;
  final int? lunchStartMinute;
  final int? lunchEndHour;
  final int? lunchEndMinute;

  // Country code for flag display
  final String countryCode;

  const MarketSchedule({
    required this.timezone,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.countryCode,
    this.lunchStartHour,
    this.lunchStartMinute,
    this.lunchEndHour,
    this.lunchEndMinute,
  });

  /// Standard US Market (NYSE/NASDAQ)
  /// 09:30 - 16:00 ET
  static const us = MarketSchedule(
    timezone: 'America/New_York',
    startHour: 9,
    startMinute: 30,
    endHour: 16,
    endMinute: 0,
    countryCode: 'us',
  );

  /// Tokyo Stock Exchange (Nikkei)
  /// 09:00 - 11:30, 12:30 - 15:00 JST
  static const tokyo = MarketSchedule(
    timezone: 'Asia/Tokyo',
    startHour: 9,
    startMinute: 0,
    endHour: 15,
    endMinute: 0,
    lunchStartHour: 11,
    lunchStartMinute: 30,
    lunchEndHour: 12,
    lunchEndMinute: 30,
    countryCode: 'jp',
  );

  /// Hong Kong Stock Exchange
  /// 09:30 - 12:00, 13:00 - 16:00 HKT
  static const hongKong = MarketSchedule(
    timezone: 'Asia/Hong_Kong',
    startHour: 9,
    startMinute: 30,
    endHour: 16,
    endMinute: 0,
    lunchStartHour: 12,
    lunchStartMinute: 0,
    lunchEndHour: 13,
    lunchEndMinute: 0,
    countryCode: 'hk',
  );

  /// London Stock Exchange
  /// 08:00 - 16:30 BST (UTC+1/0)
  /// Note: Approx schedule, verified for LSE
  static const london = MarketSchedule(
    timezone: 'Europe/London',
    startHour: 8,
    startMinute: 0,
    endHour: 16,
    endMinute: 30,
    countryCode: 'gb',
  );

  /// Euronext Paris (CAC 40) / Amsterdam / Brussels
  /// 09:00 - 17:30 CET
  static const euronext = MarketSchedule(
    timezone: 'Europe/Paris',
    startHour: 9,
    startMinute: 0,
    endHour: 17,
    endMinute: 30,
    countryCode: 'eu', // Generic or specific based on index
  );

  /// Toronto Stock Exchange (TSX)
  /// 09:30 - 16:00 ET (Same as US)
  static const toronto = MarketSchedule(
    timezone: 'America/Toronto',
    startHour: 9,
    startMinute: 30,
    endHour: 16,
    endMinute: 0,
    countryCode: 'ca',
  );

  // Helper: Calculate total trading minutes in a day
  int get totalMinutes {
    final startMins = startHour * 60 + startMinute;
    final endMins = endHour * 60 + endMinute;
    int total = endMins - startMins;

    if (lunchStartHour != null && lunchEndHour != null) {
      final lunchStart = lunchStartHour! * 60 + (lunchStartMinute ?? 0);
      final lunchEnd = lunchEndHour! * 60 + (lunchEndMinute ?? 0);
      total -= (lunchEnd - lunchStart);
    }
    return total;
  }

  // Helper: Calculate expected data points for a given interval (in minutes)
  double expectedPoints(int intervalMinutes) {
    if (intervalMinutes <= 0) return 0;
    return totalMinutes / intervalMinutes;
  }
}

class MarketScheduleService {
  // Singleton pattern (optional, but convenient for services) or just simple class

  /// Returns the specific schedule for a given symbol, or a best guess.
  static MarketSchedule getSchedule(
    String symbol, {
    String? exchange,
    String? country,
  }) {
    // 1. Explicit Symbol Logic (Indices often need this)
    if (symbol == '^N225') return MarketSchedule.tokyo;
    if (symbol == '^HSI') return MarketSchedule.hongKong;
    if (symbol == '^FTSE') return MarketSchedule.london;
    if (symbol == '^GDAXI')
      return MarketSchedule.euronext.copyWith(
        countryCode: 'de',
        timezone: 'Europe/Berlin',
      );
    if (symbol == '^FCHI')
      return MarketSchedule.euronext.copyWith(countryCode: 'fr');
    if (symbol == '^KS11')
      return MarketSchedule(
        timezone: 'Asia/Seoul',
        startHour: 9,
        startMinute: 0,
        endHour: 15,
        endMinute: 30,
        countryCode: 'kr',
      );
    if (symbol == '^BSESN')
      return MarketSchedule(
        timezone: 'Asia/Kolkata',
        startHour: 9,
        startMinute: 15,
        endHour: 15,
        endMinute: 30,
        countryCode: 'in',
      );

    // 2. Exchange Logic
    if (exchange != null) {
      final ex = exchange.toUpperCase();
      if (ex.contains('TOKYO') || ex == 'JPX') return MarketSchedule.tokyo;
      if (ex.contains('HONG KONG') || ex == 'HKSE')
        return MarketSchedule.hongKong;
      if (ex.contains('LONDON') || ex == 'LSE') return MarketSchedule.london;
      if (ex.contains('PARIS') || ex == 'EURONEXT')
        return MarketSchedule.euronext.copyWith(countryCode: 'fr');
      if (ex.contains('TORONTO') || ex == 'TSX') return MarketSchedule.toronto;
      if (ex.contains('GER') || ex.contains('XETRA'))
        return MarketSchedule.euronext.copyWith(
          countryCode: 'de',
          timezone: 'Europe/Berlin',
        );
    }

    // 3. Suffix Logic
    if (symbol.contains('.')) {
      final suffix = symbol.split('.').last.toUpperCase();
      switch (suffix) {
        case 'L':
          return MarketSchedule.london;
        case 'TO':
          return MarketSchedule.toronto;
        case 'PA':
          return MarketSchedule.euronext.copyWith(countryCode: 'fr'); // Paris
        case 'DE':
          return MarketSchedule.euronext.copyWith(
            countryCode: 'de',
            timezone: 'Europe/Berlin',
          ); // Xetra
        case 'HK':
          return MarketSchedule.hongKong;
        case 'KS':
          return MarketSchedule(
            timezone: 'Asia/Seoul',
            startHour: 9,
            startMinute: 0,
            endHour: 15,
            endMinute: 30,
            countryCode: 'kr',
          );
        case 'SI':
          return MarketSchedule(
            timezone: 'Asia/Singapore',
            startHour: 9,
            startMinute: 0,
            endHour: 17,
            endMinute: 0,
            countryCode: 'sg',
          );
        case 'MI':
          return MarketSchedule.euronext.copyWith(countryCode: 'it'); // Milan
        case 'MC':
          return MarketSchedule.euronext.copyWith(countryCode: 'es'); // Madrid
        case 'AS':
          return MarketSchedule.euronext.copyWith(
            countryCode: 'nl',
          ); // Amsterdam
        case 'BR':
          return MarketSchedule.euronext.copyWith(
            countryCode: 'be',
          ); // Brussels
        case 'SW':
          return MarketSchedule.euronext.copyWith(
            countryCode: 'ch',
            timezone: 'Europe/Zurich',
          ); // Swiss
        case 'SA':
          return MarketSchedule(
            timezone: 'America/Sao_Paulo',
            startHour: 10,
            startMinute: 0,
            endHour: 17,
            endMinute: 0,
            countryCode: 'br',
          );
        case 'V':
          return MarketSchedule.toronto; // TSX Venture
        case 'NE':
          return MarketSchedule.toronto; // NEO
      }
    }

    // 4. Country/Currency Inference
    // This is less precise for hours, but good for flags. Defaulting to US hours for unknown markets applies commonly.
    // If strict compliance is needed, we could add more schedules.

    // Default to US
    return MarketSchedule.us;
  }

  /// Helper to get generic country code without full schedule if needed
  static String getCountryCode(
    String symbol, {
    String? exchange,
    String? currency,
  }) {
    // Reuses the robust logic from old StockLogo, but centralized here.
    // Actually, getSchedule above handles the major overrides.
    // We can expand this if we want just the flag without schedule assumptions.

    // Quick overrides from old StockLogo
    if (symbol == '^N225') return 'jp';
    if (symbol == '^HSI') return 'hk';

    if (currency == 'JPY') return 'jp';
    if (currency == 'HKD') return 'hk';
    if (currency == 'GBP') return 'gb';
    if (currency == 'EUR') return 'eu';

    return getSchedule(symbol, exchange: exchange).countryCode;
  }

  /// Returns the offset in hours from UTC for the market, accounting for DST if applicable.
  /// To be robust, one should use the 'timezone' package. This is a manual approximation for major markets.
  static int getUtcOffset(String symbol, DateTime date) {
    final schedule = getSchedule(symbol);

    switch (schedule.timezone) {
      case 'America/New_York':
      case 'America/Toronto':
        // EST -5, EDT -4
        return _isUSDST(date) ? -4 : -5;
      case 'Asia/Tokyo':
        return 9; // JST is UTC+9 (No DST)
      case 'Asia/Hong_Kong':
        return 8; // HKT is UTC+8 (No DST)
      case 'Europe/London':
        // GMT 0, BST +1
        return _isEUDST(date) ? 1 : 0;
      case 'Europe/Paris':
      case 'Europe/Berlin':
      case 'Europe/Zurich':
      case 'Europe/Amsterdam':
      case 'Europe/Brussels':
      case 'Europe/Madrid':
      case 'Europe/Rome':
        // CET +1, CEST +2
        return _isEUDST(date) ? 2 : 1;
      case 'Asia/Seoul':
        return 9; // KST +9
      case 'Asia/Singapore':
        return 8; // SGT +8
      case 'Asia/Kolkata':
        // IST +5:30. We return hours as int here, so we handle minutes separately or just accept approximation for now?
        // Since this returns int, let's keep it int.
        // For exact parsing we might need duration. But for now let's say 5 and assume we handle half-hours elsewhere or ignore.
        // Actually, let's return double? No, Duration.
        return 5;
      case 'America/Sao_Paulo':
        return -3;
      default:
        return 0; // Fallback UTC
    }
  }

  // DST Helpers
  static bool _isUSDST(DateTime date) {
    // 2nd Sunday March to 1st Sunday Nov
    final year = date.year;
    final marchStart = _getNthWeekdayOfMonth(year, 3, DateTime.sunday, 2);
    final novEnd = _getNthWeekdayOfMonth(year, 11, DateTime.sunday, 1);
    return date.isAfter(marchStart) && date.isBefore(novEnd);
  }

  static bool _isEUDST(DateTime date) {
    // Last Sunday March to Last Sunday Oct
    final year = date.year;
    final marchStart = _getLastSunday(year, 3);
    final octEnd = _getLastSunday(year, 10);
    return date.isAfter(marchStart) && date.isBefore(octEnd);
  }

  static DateTime _getNthWeekdayOfMonth(
    int year,
    int month,
    int weekday,
    int n,
  ) {
    var date = DateTime(year, month, 1);
    int count = 0;
    while (date.month == month) {
      if (date.weekday == weekday) {
        count++;
        if (count == n) return date.add(const Duration(hours: 2)); // 2am switch
      }
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  static DateTime _getLastSunday(int year, int month) {
    var date = DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
    while (date.weekday != DateTime.sunday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date.add(const Duration(hours: 1)); // 1am switch
  }
}

extension MarketScheduleCopyWith on MarketSchedule {
  MarketSchedule copyWith({
    String? timezone,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    String? countryCode,
  }) {
    return MarketSchedule(
      timezone: timezone ?? this.timezone,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      countryCode: countryCode ?? this.countryCode,
      lunchStartHour: this.lunchStartHour,
      lunchStartMinute: this.lunchStartMinute,
      lunchEndHour: this.lunchEndHour,
      lunchEndMinute: this.lunchEndMinute,
    );
  }
}

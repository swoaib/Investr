class CurrencyConversion {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final double amount;

  const CurrencyConversion({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    this.amount = 1.0,
  });

  // Helper to get flag asset name (e.g. 'USD' -> 'us')
  // This is a simple heuristic, mapped manually for accuracy
  String get baseFlag => _getFlag(baseCurrency);
  String get targetFlag => _getFlag(targetCurrency);

  static String _getFlag(String currencyCode) {
    if (currencyCode == 'EUR') return 'eu';
    if (currencyCode == 'GBP') return 'gb';
    // Default: try to match first two letters
    return currencyCode.substring(0, 2).toLowerCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'targetCurrency': targetCurrency,
      'rate': rate,
      'amount': amount,
    };
  }

  factory CurrencyConversion.fromJson(Map<String, dynamic> json) {
    return CurrencyConversion(
      baseCurrency: json['baseCurrency'] as String,
      targetCurrency: json['targetCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

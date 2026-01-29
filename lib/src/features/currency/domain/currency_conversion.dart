class CurrencyConversion {
  final String id;
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final double amount;

  const CurrencyConversion({
    required this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    this.amount = 1.0,
  });

  factory CurrencyConversion.create({
    required String baseCurrency,
    required String targetCurrency,
    required double rate,
    double amount = 1.0,
  }) {
    return CurrencyConversion(
      id: DateTime.now().microsecondsSinceEpoch.toString(), // Simple unique ID
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
      rate: rate,
      amount: amount,
    );
  }

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
      'id': id,
      'baseCurrency': baseCurrency,
      'targetCurrency': targetCurrency,
      'rate': rate,
      'amount': amount,
    };
  }

  factory CurrencyConversion.fromJson(Map<String, dynamic> json) {
    return CurrencyConversion(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      baseCurrency: json['baseCurrency'] as String,
      targetCurrency: json['targetCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyConversion &&
        other.id == id &&
        other.baseCurrency == baseCurrency &&
        other.targetCurrency == targetCurrency &&
        other.rate == rate &&
        other.amount == amount;
  }

  @override
  int get hashCode =>
      Object.hash(id, baseCurrency, targetCurrency, rate, amount);
}

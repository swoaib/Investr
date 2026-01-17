class AdvancedDCFData {
  final String symbol;
  final double dcf;
  final double stockPrice;
  final String date;

  // Breakdown fields
  final double wacc;
  final double taxRate;
  final double riskFreeRate;
  final double beta;
  final double costOfEquity;
  final double afterTaxCostOfDebt;
  final double longTermGrowthRate;
  final double enterpriseValue;
  final double equityValue;

  AdvancedDCFData({
    required this.symbol,
    required this.dcf,
    required this.stockPrice,
    required this.date,
    this.wacc = 0.0,
    this.taxRate = 0.0,
    this.riskFreeRate = 0.0,
    this.beta = 0.0,
    this.costOfEquity = 0.0,
    this.afterTaxCostOfDebt = 0.0,
    this.longTermGrowthRate = 0.0,
    this.enterpriseValue = 0.0,
    this.equityValue = 0.0,
  });

  factory AdvancedDCFData.fromJson(Map<String, dynamic> json) {
    return AdvancedDCFData(
      symbol: json['symbol'] as String? ?? '',
      // For Custom DCF endpoint, 'equityValuePerShare' is the calculated intrinsic value
      dcf: (json['equityValuePerShare'] as num?)?.toDouble() ?? 0.0,
      // 'price' is the current stock price in this endpoint
      stockPrice: (json['price'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',

      wacc: (json['wacc'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      riskFreeRate: (json['riskFreeRate'] as num?)?.toDouble() ?? 0.0,
      beta: (json['beta'] as num?)?.toDouble() ?? 0.0,
      costOfEquity: (json['costOfEquity'] as num?)?.toDouble() ?? 0.0,
      afterTaxCostOfDebt:
          (json['afterTaxCostOfDebt'] as num?)?.toDouble() ?? 0.0,
      longTermGrowthRate:
          (json['longTermGrowthRate'] as num?)?.toDouble() ?? 0.0,
      enterpriseValue: (json['enterpriseValue'] as num?)?.toDouble() ?? 0.0,
      equityValue: (json['equityValue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

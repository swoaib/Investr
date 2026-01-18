class EarningsPoint {
  final String period; // e.g. "Q3 23"
  final double eps;
  final double revenue;
  final String? reportedCurrency;
  final double? exchangeRateUsed;
  final String? originalCurrency;
  final double netIncome;
  final double grossProfit;
  final double operatingIncome;
  final double? originalRevenue;
  final double? originalEps;
  final double? originalNetIncome;
  final double? originalGrossProfit;
  final double? originalOperatingIncome;

  EarningsPoint({
    required this.period,
    required this.eps,
    required this.revenue,
    this.reportedCurrency,
    this.exchangeRateUsed,
    this.originalCurrency,
    this.netIncome = 0.0,
    this.grossProfit = 0.0,
    this.operatingIncome = 0.0,
    this.originalRevenue,
    this.originalEps,
    this.originalNetIncome,
    this.originalGrossProfit,
    this.originalOperatingIncome,
  });
}

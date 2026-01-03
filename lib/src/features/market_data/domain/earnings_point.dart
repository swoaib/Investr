class EarningsPoint {
  final String period; // e.g. "Q3 23"
  final double eps;
  final double revenue;
  final double netIncome;
  final double grossProfit;
  final double operatingIncome;

  EarningsPoint({
    required this.period,
    required this.eps,
    required this.revenue,
    this.netIncome = 0.0,
    this.grossProfit = 0.0,
    this.operatingIncome = 0.0,
  });
}

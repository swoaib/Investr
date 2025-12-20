class EarningsPoint {
  final String period; // e.g. "Q3 23"
  final double eps;
  final double revenue;

  EarningsPoint({
    required this.period,
    required this.eps,
    required this.revenue,
  });
}

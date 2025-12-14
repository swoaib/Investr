class Stock {
  final String symbol;
  final String companyName;
  final double price;
  final double change;
  final double changePercent;

  const Stock({
    required this.symbol,
    required this.companyName,
    required this.price,
    required this.change,
    required this.changePercent,
    this.marketCap,
    this.peRatio,
    this.dividendYield,
    this.earningsPerShare,
    this.description,
    this.employees,
    this.high52Week,
    this.low52Week,
  });

  final double? marketCap;
  final double? peRatio;
  final double? dividendYield;
  final double? earningsPerShare;
  final String? description;
  final int? employees;
  final double? high52Week;
  final double? low52Week;

  bool get isPositive => change >= 0;
}

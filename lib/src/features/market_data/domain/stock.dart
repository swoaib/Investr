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
  });

  bool get isPositive => change >= 0;
}

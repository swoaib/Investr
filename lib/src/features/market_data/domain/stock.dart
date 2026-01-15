import 'price_point.dart';
import 'earnings_point.dart';

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
    this.previousClose,
    this.marketCap,
    this.peRatio,
    this.dividendYield,
    this.earningsPerShare,
    this.description,
    this.employees,
    this.high52Week,
    this.low52Week,
    this.sparklineData,
    this.earningsHistory,
    this.country,
    this.exchange,
    this.currency,
  });

  final double? previousClose;
  final double? marketCap;
  final double? peRatio;
  final double? dividendYield;
  final double? earningsPerShare;
  final String? description;
  final int? employees;
  final String? country;
  final String? exchange;
  final String? currency;
  final double? high52Week;
  final double? low52Week;

  /// Intraday price points for mini sparkline chart
  final List<PricePoint>? sparklineData;

  /// Historical earnings data for the Earnings chart
  final List<EarningsPoint>? earningsHistory;

  bool get isPositive => change >= 0;

  String get imageUrl =>
      'https://images.financialmodelingprep.com/symbol/$symbol.png';

  Stock copyWith({
    String? symbol,
    String? companyName,
    double? price,
    double? change,
    double? changePercent,
    double? previousClose,
    double? marketCap,
    double? peRatio,
    double? dividendYield,
    double? earningsPerShare,
    String? description,
    int? employees,
    double? high52Week,
    double? low52Week,
    List<PricePoint>? sparklineData,
    List<EarningsPoint>? earningsHistory,
    String? country,
    String? exchange,
    String? currency,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      previousClose: previousClose ?? this.previousClose,
      marketCap: marketCap ?? this.marketCap,
      peRatio: peRatio ?? this.peRatio,
      dividendYield: dividendYield ?? this.dividendYield,
      earningsPerShare: earningsPerShare ?? this.earningsPerShare,
      description: description ?? this.description,
      employees: employees ?? this.employees,
      high52Week: high52Week ?? this.high52Week,
      low52Week: low52Week ?? this.low52Week,
      sparklineData: sparklineData ?? this.sparklineData,
      earningsHistory: earningsHistory ?? this.earningsHistory,
      country: country ?? this.country,
      exchange: exchange ?? this.exchange,
      currency: currency ?? this.currency,
    );
  }

  /// Create a copy with sparkline data added
  Stock copyWithSparkline(List<PricePoint> data) {
    return copyWith(sparklineData: data);
  }

  Stock copyWithEarnings(List<EarningsPoint> data) {
    return copyWith(earningsHistory: data);
  }
}

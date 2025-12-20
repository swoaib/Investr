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
  });

  final double? marketCap;
  final double? peRatio;
  final double? dividendYield;
  final double? earningsPerShare;
  final String? description;
  final int? employees;
  final double? high52Week;
  final double? low52Week;

  /// Intraday price points for mini sparkline chart
  final List<PricePoint>? sparklineData;

  /// Historical earnings data for the Earnings chart
  final List<EarningsPoint>? earningsHistory;

  bool get isPositive => change >= 0;

  /// Create a copy with sparkline data added
  Stock copyWithSparkline(List<PricePoint> data) {
    return Stock(
      symbol: symbol,
      companyName: companyName,
      price: price,
      change: change,
      changePercent: changePercent,
      marketCap: marketCap,
      peRatio: peRatio,
      dividendYield: dividendYield,
      earningsPerShare: earningsPerShare,
      description: description,
      employees: employees,
      high52Week: high52Week,
      low52Week: low52Week,
      sparklineData: data,
      earningsHistory: earningsHistory,
    );
  }

  Stock copyWithEarnings(List<EarningsPoint> data) {
    return Stock(
      symbol: symbol,
      companyName: companyName,
      price: price,
      change: change,
      changePercent: changePercent,
      marketCap: marketCap,
      peRatio: peRatio,
      dividendYield: dividendYield,
      earningsPerShare: earningsPerShare,
      description: description,
      employees: employees,
      high52Week: high52Week,
      low52Week: low52Week,
      sparklineData: sparklineData,
      earningsHistory: data,
    );
  }
}

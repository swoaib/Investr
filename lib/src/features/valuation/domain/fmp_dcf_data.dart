class FMPDCFData {
  final String symbol;
  final double dcf;
  final double stockPrice;
  final String date;

  FMPDCFData({
    required this.symbol,
    required this.dcf,
    required this.stockPrice,
    required this.date,
  });

  factory FMPDCFData.fromJson(Map<String, dynamic> json) {
    return FMPDCFData(
      symbol: json['symbol'] as String,
      dcf: (json['dcf'] as num).toDouble(),
      stockPrice: (json['Stock Price'] as num).toDouble(),
      date: json['date'] as String,
    );
  }
}

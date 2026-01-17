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
  final double terminalValue;
  final double presentTerminalValue;
  final double sumPvUfcf;
  final double netDebt;
  final double totalDebt;
  final double totalCash;
  final double dilutedSharesOutstanding;
  final List<YearlyDCFData> yearlyData;

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
    this.terminalValue = 0.0,
    this.presentTerminalValue = 0.0,
    this.sumPvUfcf = 0.0,
    this.netDebt = 0.0,
    this.totalDebt = 0.0,
    this.totalCash = 0.0,
    this.dilutedSharesOutstanding = 1.0,
    this.yearlyData = const [],
  });

  factory AdvancedDCFData.fromJson(dynamic jsonInput) {
    Map<String, dynamic> json;
    List<YearlyDCFData> yearlyData = [];

    if (jsonInput is List && jsonInput.isNotEmpty) {
      // The API returns a list of years. The first item often contains the summary for the terminal year
      // OR the "current" valuation summary.
      // We will take the first item as the "summary" source, but parse the whole list for charts.
      json = jsonInput[0] as Map<String, dynamic>;
      yearlyData = jsonInput
          .map((e) => YearlyDCFData.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (jsonInput is Map<String, dynamic>) {
      json = jsonInput;
    } else {
      // Fallback
      json = {};
    }

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

      terminalValue: (json['terminalValue'] as num?)?.toDouble() ?? 0.0,
      presentTerminalValue:
          (json['presentTerminalValue'] as num?)?.toDouble() ?? 0.0,
      sumPvUfcf: (json['sumPvUfcf'] as num?)?.toDouble() ?? 0.0,
      netDebt: (json['netDebt'] as num?)?.toDouble() ?? 0.0,
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
      totalCash: (json['totalCash'] as num?)?.toDouble() ?? 0.0,
      dilutedSharesOutstanding:
          (json['dilutedSharesOutstanding'] as num?)?.toDouble() ?? 1.0,

      yearlyData: yearlyData,
    );
  }
}

class YearlyDCFData {
  final int year;
  final double revenue;
  final double ebitda;
  final double ufcf; // Unlevered Free Cash Flow

  YearlyDCFData({
    required this.year,
    required this.revenue,
    required this.ebitda,
    required this.ufcf,
  });

  factory YearlyDCFData.fromJson(Map<String, dynamic> json) {
    // Parse year as int, handle potential string or dynamic
    int parsedYear = 0;
    if (json['year'] is int) {
      parsedYear = json['year'];
    } else if (json['year'] is String) {
      parsedYear = int.tryParse(json['year']) ?? 0;
    }

    return YearlyDCFData(
      year: parsedYear,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      ebitda: (json['ebitda'] as num?)?.toDouble() ?? 0.0,
      ufcf: (json['ufcf'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

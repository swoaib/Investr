class DCFData {
  final String symbol;
  final double freeCashFlow; // Operating Cash Flow - CapEx
  final double netDebt; // Total Debt - Cash
  final double sharesOutstanding;
  final double price; // Current market price for comparison

  const DCFData({
    required this.symbol,
    required this.freeCashFlow,
    required this.netDebt,
    required this.sharesOutstanding,
    required this.price,
  });

  // Empty/Error state
  factory DCFData.empty() {
    return const DCFData(
      symbol: '',
      freeCashFlow: 0,
      netDebt: 0,
      sharesOutstanding: 0,
      price: 0,
    );
  }
}

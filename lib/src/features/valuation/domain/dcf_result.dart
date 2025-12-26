class DCFResult {
  final double intrinsicValue;
  final double equityValue;
  final double enterpriseValue;
  final double terminalValue;
  final double presentTerminalValue;
  final Map<int, double> futureCashFlows;
  final Map<int, double> discountedCashFlows;
  final double netDebt;
  final double sharesOutstanding;

  const DCFResult({
    required this.intrinsicValue,
    required this.equityValue,
    required this.enterpriseValue,
    required this.terminalValue,
    required this.presentTerminalValue,
    required this.futureCashFlows,
    required this.discountedCashFlows,
    required this.netDebt,
    required this.sharesOutstanding,
  });
}

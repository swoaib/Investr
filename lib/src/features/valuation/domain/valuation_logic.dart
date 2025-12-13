import 'dart:math';

class ValuationLogic {
  /// Calculates the intrinsic value based on Discounted Cash Flow of earnings for [years].
  /// This is a simplified model summing the present value of future earnings.
  static double calculateDCF({
    required double eps,
    required double growthRate, // in percent, e.g. 10 for 10%
    required double discountRate, // in percent, e.g. 8 for 8%
    required int years,
  }) {
    double totalValue = 0.0;
    double currentEps = eps;
    final r = discountRate / 100;
    final g = growthRate / 100;

    for (int i = 1; i <= years; i++) {
      // Future EPS
      currentEps = currentEps * (1 + g);

      // Present Value of that EPS
      double presentValue = currentEps / pow(1 + r, i);

      totalValue += presentValue;
    }

    return totalValue;
  }
}

import 'dart:math';
import 'dcf_result.dart';

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

  /// Calculates Intrinsic Value using "Real" DCF with Free Cash Flow and Terminal Value.
  static DCFResult calculateRealDCF({
    required double freeCashFlow,
    required double growthRate, // in percent per year (for projection period)
    required double discountRate, // WACC in percent
    required double terminalGrowthRate, // in percent (perpetuity growth)
    required int years, // projection period
    required double netDebt,
    required double sharesOutstanding,
  }) {
    double totalEnterpriseValue = 0.0;
    double currentFCF = freeCashFlow;
    final r = discountRate / 100;
    final g = growthRate / 100;
    final gTerm = terminalGrowthRate / 100;

    final Map<int, double> futureCashFlows = {};
    final Map<int, double> discountedCashFlows = {};

    // 1. Sum of Present Value of Future Free Cash Flows
    for (int i = 1; i <= years; i++) {
      currentFCF = currentFCF * (1 + g);
      double presentValue = currentFCF / pow(1 + r, i);

      futureCashFlows[i] = currentFCF;
      discountedCashFlows[i] = presentValue;

      totalEnterpriseValue += presentValue;
    }

    // 2. Terminal Value (Gordon Growth Model) at year N
    // TV = FCF * (1 + gTerm) / (r - gTerm)
    // We use the FCF of the last projected year (currentFCF at this point is Year N's FCF)
    // Strictly, Gordon Growth uses Year N+1 FCF
    double fcfNPlus1 = currentFCF * (1 + gTerm);
    double terminalValue = (r - gTerm) == 0 ? 0 : fcfNPlus1 / (r - gTerm);

    // Discount Terminal Value to Present
    double presentTerminalValue = terminalValue / pow(1 + r, years);

    totalEnterpriseValue += presentTerminalValue;

    // 3. Equity Value = Enterprise Value - Net Debt (Total Debt - Cash)
    // If Net Debt is negative (Cash > Debt), we ADD cash to EV to get Equity Value.
    // Logic: Equity = EV - Debt + Cash = EV - (Debt - Cash) = EV - NetDebt.
    double equityValue = totalEnterpriseValue - netDebt;

    // 4. Per Share Value
    double intrinsicValue = 0;
    if (sharesOutstanding > 0) {
      intrinsicValue = equityValue / sharesOutstanding;
    }

    return DCFResult(
      intrinsicValue: intrinsicValue,
      equityValue: equityValue,
      enterpriseValue: totalEnterpriseValue,
      terminalValue: terminalValue,
      presentTerminalValue: presentTerminalValue,
      futureCashFlows: futureCashFlows,
      discountedCashFlows: discountedCashFlows,
      netDebt: netDebt,
      sharesOutstanding: sharesOutstanding,
    );
  }
}

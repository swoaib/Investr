import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../domain/earnings_point.dart';
import '../../../shared/theme/app_theme.dart';

class EarningsChart extends StatelessWidget {
  final List<EarningsPoint> earnings;
  final bool isLoading;

  const EarningsChart({
    super.key,
    required this.earnings,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (earnings.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('No earning history available')),
      );
    }

    final theme = Theme.of(context);
    final color = AppTheme.primaryGreen;

    // Find max Y for some padding
    double maxY = 0;
    for (var e in earnings) {
      if (e.eps > maxY) maxY = e.eps;
    }
    maxY = maxY * 1.2; // 20% buffer

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Earnings History",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Quarterly Earnings (EPS)",
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '\$${rod.toY.toStringAsFixed(2)}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < earnings.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              earnings[index].period,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '\$${value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: null,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: earnings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final point = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: point.eps,
                        color: color,
                        width: 24,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        // Show label on top if desired, but tooltip is often cleaner
                      ),
                    ],
                    showingTooltipIndicators: [0], // Show value always on top?
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

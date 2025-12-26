import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../domain/earnings_point.dart';
import '../../../shared/theme/app_theme.dart';
import 'package:investr/l10n/app_localizations.dart';

class EarningsChart extends StatelessWidget {
  final List<EarningsPoint> earnings;
  final bool isLoading;
  final String metric; // 'EPS' or 'Revenue'

  const EarningsChart({
    super.key,
    required this.earnings,
    this.isLoading = false,
    this.metric = 'EPS',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppTheme.primaryGreen;
    final isRevenue = metric == 'Revenue';
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header is moved to parent or we can keep a dynamic subtitle here
          Text(
            isRevenue ? l10n.revenueHistory : l10n.earningsHistory,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isRevenue ? l10n.revenueUSD : l10n.earningsPerShare,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : earnings.isEmpty
                ? Center(child: Text(l10n.noEarningsHistory))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _calculateMaxY(isRevenue),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => theme.cardColor,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              _formatValue(rod.toY, isRevenue),
                              TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
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
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  _formatAxisValue(value, isRevenue),
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
                        horizontalInterval: _calculateMaxY(isRevenue) / 5,
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
                              toY: isRevenue ? point.revenue : point.eps,
                              color: color,
                              width: 16,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY(bool isRevenue) {
    if (earnings.isEmpty) return 10;
    double maxY = 0;
    for (var e in earnings) {
      final val = isRevenue ? e.revenue : e.eps;
      if (val > maxY) maxY = val;
    }
    return maxY == 0 ? 10 : maxY * 1.2; // 20% buffer
  }

  String _formatValue(double value, bool isRevenue) {
    if (isRevenue) {
      if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
      if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
      return '\$${value.toStringAsFixed(0)}';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatAxisValue(double value, bool isRevenue) {
    if (isRevenue) {
      if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(1)}B';
      if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(1)}M';
      return '\$${value.toStringAsFixed(0)}';
    }
    return '\$${value.toStringAsFixed(1)}';
  }
}

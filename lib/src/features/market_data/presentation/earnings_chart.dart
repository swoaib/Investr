import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../domain/earnings_point.dart';
import '../../../shared/theme/app_theme.dart';
import 'package:investr/l10n/app_localizations.dart';

import 'dart:math';

class EarningsChart extends StatefulWidget {
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
  State<EarningsChart> createState() => _EarningsChartState();
}

class _EarningsChartState extends State<EarningsChart> {
  final ScrollController _scrollController = ScrollController();

  List<EarningsPoint> get earnings => widget.earnings;
  bool get isLoading => widget.isLoading;
  String get metric => widget.metric;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void didUpdateWidget(EarningsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.isLoading && !widget.isLoading) ||
        (oldWidget.earnings.length != widget.earnings.length)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // color variable was unused
    final isRevenue = metric == 'Revenue';
    final l10n = AppLocalizations.of(context)!;

    final scale = _calculateNiceScale(isRevenue);

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
                : Row(
                    children: [
                      SizedBox(
                        width: 45,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.center,
                            maxY: scale.maxY,
                            minY: scale.minY,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: scale.interval,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const SizedBox();
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 4.0,
                                      ),
                                      child: Text(
                                        _formatAxisValue(value, isRevenue),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) =>
                                      const SizedBox(),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [],
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: max(
                              MediaQuery.of(context).size.width - 32 - 35,
                              earnings.length * 42.0,
                            ),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: scale.maxY,
                                minY: scale.minY,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    fitInsideHorizontally: true,
                                    fitInsideVertically: true,
                                    getTooltipColor: (group) => theme.cardColor,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            _formatValue(rod.toY, isRevenue),
                                            TextStyle(
                                              color: theme
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
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
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 &&
                                            index < earnings.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
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
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
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
                                  horizontalInterval: scale.interval,
                                  getDrawingHorizontalLine: (value) {
                                    // Highlight zero line slightly more visible
                                    if (value == 0) {
                                      return FlLine(
                                        color: Colors.grey.withValues(
                                          alpha: 0.3,
                                        ),
                                        strokeWidth: 1,
                                      );
                                    }
                                    return FlLine(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: earnings.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final point = entry.value;
                                  final val = switch (metric) {
                                    'Revenue' => point.revenue,
                                    'Net Income' => point.netIncome,
                                    'Gross Profit' => point.grossProfit,
                                    'Operating Income' => point.operatingIncome,
                                    _ => point.eps,
                                  };
                                  final isNegative = val < 0;

                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: val,
                                        color: isNegative
                                            ? AppTheme.errorRed
                                            : AppTheme.primaryGreen,
                                        width: 25,
                                        borderRadius: BorderRadius.only(
                                          topLeft: isNegative
                                              ? Radius.zero
                                              : const Radius.circular(4),
                                          topRight: isNegative
                                              ? Radius.zero
                                              : const Radius.circular(4),
                                          bottomLeft: isNegative
                                              ? const Radius.circular(4)
                                              : Radius.zero,
                                          bottomRight: isNegative
                                              ? const Radius.circular(4)
                                              : Radius.zero,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  ({double maxY, double minY, double interval}) _calculateNiceScale(
    bool isRevenue,
  ) {
    if (earnings.isEmpty) return (maxY: 10, minY: 0, interval: 2);

    double maxVal = 0;
    // Initialize minVal to 0 to ensure positive bars start from baseline
    double minVal = 0;

    for (var e in earnings) {
      final val = switch (metric) {
        'Revenue' => e.revenue,
        'Net Income' => e.netIncome,
        'Gross Profit' => e.grossProfit,
        'Operating Income' => e.operatingIncome,
        _ => e.eps,
      };
      if (val > maxVal) maxVal = val;
      if (val < minVal) minVal = val;
    }

    // Determine the magnitude based on the larger absolute extent
    final double absMax = max(maxVal.abs(), minVal.abs());

    // If effectively zero
    if (absMax <= 0) return (maxY: 10, minY: 0, interval: 2);

    // nice number algorithm
    final mag = pow(10, (log(absMax) / log(10)).floor()).toDouble();
    final norm = absMax / mag; // between 1.0 and 10.0

    double step;
    if (norm <= 1.0) {
      step = 0.2;
    } else if (norm <= 2.0) {
      step = 0.5;
    } else if (norm <= 5.0) {
      step = 1.0;
    } else {
      step = 2.0;
    }

    final interval = step * mag;
    final niceMax = (maxVal / interval).ceil() * interval;
    final niceMin = (minVal / interval).floor() * interval;

    // Ensure we have at least a little headroom if the bar equals exact niceMax
    final finalMax = niceMax == maxVal ? niceMax + interval : niceMax;
    // Don't pad below zero or negative values unnecessarily
    final finalMin = niceMin;

    return (maxY: finalMax, minY: finalMin, interval: interval);
  }

  String _formatValue(double value, bool isRevenue) {
    // Large number formatting for Revenue, Net Income, etc.
    if (metric != 'EPS') {
      final absVal = value.abs();
      if (absVal >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
      if (absVal >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
      return '\$${value.toStringAsFixed(0)}';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatAxisValue(double value, bool isRevenue) {
    if (metric != 'EPS') {
      final absVal = value.abs();
      if (absVal >= 1e9) {
        return '\$${(value / 1e9).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
      }
      if (absVal >= 1e6) {
        return '\$${(value / 1e6).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
      }
      return '\$${value.toInt()}';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
}

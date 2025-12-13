import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../data/stock_repository.dart';
import '../domain/price_point.dart';
import '../domain/stock.dart';

class StockDetailBottomSheet extends StatefulWidget {
  final Stock stock;

  const StockDetailBottomSheet({super.key, required this.stock});

  @override
  State<StockDetailBottomSheet> createState() => _StockDetailBottomSheetState();
}

class _StockDetailBottomSheetState extends State<StockDetailBottomSheet> {
  final StockRepository _repository = StockRepository();
  List<PricePoint> _history = [];
  bool _isLoading = true;
  String _selectedInterval = '1M'; // Default

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _repository.getStockHistory(widget.stock.symbol);
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<PricePoint> get _filteredHistory {
    if (_history.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoff;

    switch (_selectedInterval) {
      case '1D':
        cutoff = now.subtract(const Duration(days: 1));
        break;
      case '1W':
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case '1M':
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case '1Y':
        cutoff = now.subtract(const Duration(days: 365));
        break;
      case 'All':
      default:
        return _history;
    }

    return _history.where((p) => p.date.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final points = _filteredHistory;
    final isPositive = widget.stock.isPositive;
    final color = isPositive ? AppTheme.primaryGreen : Colors.red;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stock.symbol,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.stock.companyName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(widget.stock.price),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${widget.stock.changePercent.toStringAsFixed(2)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Chart
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : points.isEmpty
                ? const Center(child: Text('No data available'))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              return LineTooltipItem(
                                // Format price as integer string
                                barSpot.y.toInt().toString(),
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: points
                              .map(
                                (p) => FlSpot(
                                  p.date.millisecondsSinceEpoch.toDouble(),
                                  p.price,
                                ),
                              )
                              .toList(),
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // Interval Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['1D', '1W', '1M', '1Y', 'All'].map((interval) {
              final isSelected = _selectedInterval == interval;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedInterval = interval;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    interval,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

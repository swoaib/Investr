import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../data/stock_repository.dart';
import '../domain/price_point.dart';
import '../domain/stock.dart';
import '../domain/earnings_point.dart';
import 'earnings_chart.dart';

class StockDetailBottomSheet extends StatefulWidget {
  final Stock stock;

  const StockDetailBottomSheet({super.key, required this.stock});

  @override
  State<StockDetailBottomSheet> createState() => _StockDetailBottomSheetState();
}

class _StockDetailBottomSheetState extends State<StockDetailBottomSheet> {
  final StockRepository _repository = StockRepository();
  List<PricePoint> _history = [];
  late Stock _stock; // Local mutable stock to hold details
  bool _isLoading = true;
  String _selectedInterval = '1D'; // Default to 1D
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  PricePoint? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch history, details, and intraday (since 1D is now default)
      final historyFuture = _repository.getStockHistory(widget.stock.symbol);
      final detailsFuture = _repository.getStockDetails(widget.stock);
      final intradayFuture = _repository.getIntradayHistory(
        widget.stock.symbol,
      );

      final results = await Future.wait([
        historyFuture,
        detailsFuture,
        intradayFuture,
      ]);

      if (mounted) {
        setState(() {
          _history = results[0] as List<PricePoint>;
          _stock = results[1] as Stock;
          _intradayHistory = results[2] as List<PricePoint>;
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

  // Cache for intraday/weekly data to avoid re-fetching
  List<PricePoint>? _intradayHistory;
  List<PricePoint>? _weeklyHistory;
  List<EarningsPoint> _earningsHistory = [];
  bool _isEarningsLoading = false;

  Future<void> _fetchDataForInterval() async {
    if (_selectedInterval == '1D' && _intradayHistory == null) {
      setState(() => _isLoading = true);
      final data = await _repository.getIntradayHistory(_stock.symbol);
      if (mounted) {
        setState(() {
          _intradayHistory = data;
          _isLoading = false;
        });
      }
    } else if (_selectedInterval == '1W' && _weeklyHistory == null) {
      setState(() => _isLoading = true);
      final data = await _repository.getWeeklyHistory(_stock.symbol);
      if (mounted) {
        setState(() {
          _weeklyHistory = data;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchEarnings() async {
    setState(() => _isEarningsLoading = true);
    final data = await _repository.getEarningsHistory(_stock.symbol);
    if (mounted) {
      setState(() {
        _earningsHistory = data;
        _isEarningsLoading = false;
      });
    }
  }

  List<PricePoint> get _filteredHistory {
    // If 1D is selected, return intraday data if available
    if (_selectedInterval == '1D') {
      if (_intradayHistory != null && _intradayHistory!.isNotEmpty) {
        return _intradayHistory!;
      }
      // Fallback if intraday fetch failed or is empty: Show last 5 days of daily data
      if (_history.isEmpty) return [];
      if (_history.length < 5) return _history;
      return _history.sublist(_history.length - 5).toList();
    }

    if (_selectedInterval == '1W') {
      if (_weeklyHistory != null && _weeklyHistory!.isNotEmpty) {
        return _weeklyHistory!;
      }
      // Fallback to daily data if weekly fails
    }

    if (_history.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoff;

    switch (_selectedInterval) {
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
      case 'Custom':
        // Custom is handled below
        cutoff = DateTime(1970); // Effectively all, then filtered
        break;
      default:
        return _history;
    }

    if (_selectedInterval == 'Custom') {
      if (_customStartDate != null && _customEndDate != null) {
        return _history.where((p) {
          return p.date.isAfter(_customStartDate!) &&
              p.date.isBefore(_customEndDate!.add(const Duration(days: 1)));
        }).toList();
      }
      return [];
    }

    return _history.where((p) => p.date.isAfter(cutoff)).toList();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customStartDate ?? now,
      firstDate: DateTime(1970),
      lastDate: _customEndDate ?? now,
    );
    if (picked != null) {
      setState(() {
        _customStartDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customEndDate ?? now,
      firstDate: _customStartDate ?? DateTime(1970),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _customEndDate = picked;
      });
    }
  }

  String _formatMarketCap(double? marketCap) {
    if (marketCap == null) return 'N/A';
    if (marketCap >= 1e12) return '\$${(marketCap / 1e12).toStringAsFixed(2)}T';
    if (marketCap >= 1e9) return '\$${(marketCap / 1e9).toStringAsFixed(2)}B';
    if (marketCap >= 1e6) return '\$${(marketCap / 1e6).toStringAsFixed(2)}M';
    return '\$${marketCap.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final points = _filteredHistory;
    final isPositive = _stock.isPositive;
    final color = isPositive ? AppTheme.primaryGreen : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(
        top: 16,
      ), // Remove horiz padding here to allow full width
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Persisting)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stock.symbol,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _stock.companyName,
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
                        _selectedPoint != null
                            ? currencyFormat.format(_selectedPoint!.price)
                            : currencyFormat.format(_stock.price),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _selectedPoint != null
                            ? _formatDate(_selectedPoint!.date)
                            : '${isPositive ? '+' : ''}${_stock.changePercent.toStringAsFixed(2)}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _selectedPoint != null ? Colors.grey : color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              dividerColor: Colors.transparent,
              indicatorColor: color,
              labelColor: color,
              unselectedLabelColor: Colors.grey,
              onTap: (index) {
                if (index == 1 &&
                    _earningsHistory.isEmpty &&
                    !_isEarningsLoading) {
                  _fetchEarnings();
                }
              },
              tabs: const [
                Tab(text: "Overview"),
                Tab(text: "Earnings"),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 500, // Fixed height for content area
              child: TabBarView(
                children: [
                  // --- OVERVIEW TAB ---
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Animated Date Buttons for Custom Interval
                          AnimatedCrossFade(
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildDateButton(
                                    'Start Date',
                                    _customStartDate,
                                    _pickStartDate,
                                    theme,
                                    color,
                                  ),
                                  _buildDateButton(
                                    'End Date',
                                    _customEndDate,
                                    _pickEndDate,
                                    theme,
                                    color,
                                  ),
                                ],
                              ),
                            ),
                            crossFadeState: _selectedInterval == 'Custom'
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),

                          // Chart
                          SizedBox(
                            height: 250,
                            child: _isLoading && _history.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : points.isEmpty
                                ? Center(
                                    child: Text(
                                      _selectedInterval == 'Custom' &&
                                              (_customStartDate == null ||
                                                  _customEndDate == null)
                                          ? 'Please select start and end dates'
                                          : 'No data available',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  )
                                : LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: null,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey.withValues(
                                              alpha: 0.2,
                                            ),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 20,
                                            interval: null,
                                            getTitlesWidget: (value, meta) {
                                              final date =
                                                  DateTime.fromMillisecondsSinceEpoch(
                                                    value.toInt(),
                                                  );

                                              // Show only first and last date to avoid crowding
                                              if (value == meta.min ||
                                                  value == meta.max) {
                                                String formatted;
                                                if (_selectedInterval == '1D') {
                                                  formatted = DateFormat(
                                                    'HH:mm',
                                                  ).format(date);
                                                } else if (_selectedInterval ==
                                                    '1W') {
                                                  formatted = DateFormat(
                                                    'EEE',
                                                  ).format(date);
                                                } else if (_selectedInterval ==
                                                    '1M') {
                                                  formatted = DateFormat(
                                                    'MMM d',
                                                  ).format(date);
                                                } else {
                                                  formatted = DateFormat(
                                                    'MMM yy',
                                                  ).format(date);
                                                }

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Text(
                                                    formatted,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox();
                                            },
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 35,
                                            maxIncluded: false,
                                            minIncluded: false,
                                            getTitlesWidget: (value, meta) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                child: Text(
                                                  '\$${value.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border(
                                          right: BorderSide(
                                            color: Colors.grey.withValues(
                                              alpha: 0.2,
                                            ),
                                            width: 1,
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.grey.withValues(
                                              alpha: 0.2,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      lineTouchData: LineTouchData(
                                        touchCallback:
                                            (
                                              FlTouchEvent event,
                                              LineTouchResponse? touchResponse,
                                            ) {
                                              if (event is FlPanEndEvent ||
                                                  event is FlLongPressEnd ||
                                                  touchResponse == null ||
                                                  touchResponse.lineBarSpots ==
                                                      null ||
                                                  touchResponse
                                                      .lineBarSpots!
                                                      .isEmpty) {
                                                setState(() {
                                                  _selectedPoint = null;
                                                });
                                                return;
                                              }

                                              final spot = touchResponse
                                                  .lineBarSpots!
                                                  .first;
                                              final date =
                                                  DateTime.fromMillisecondsSinceEpoch(
                                                    spot.x.toInt(),
                                                  );
                                              setState(() {
                                                _selectedPoint = PricePoint(
                                                  date: date,
                                                  price: spot.y,
                                                );
                                              });
                                            },
                                        handleBuiltInTouches: true,
                                        touchTooltipData: LineTouchTooltipData(
                                          getTooltipItems: (touchedBarSpots) {
                                            return touchedBarSpots
                                                .map((_) => null)
                                                .toList();
                                          },
                                        ),
                                        getTouchedSpotIndicator:
                                            (
                                              LineChartBarData barData,
                                              List<int> spotIndexes,
                                            ) {
                                              return spotIndexes.map((index) {
                                                return TouchedSpotIndicatorData(
                                                  FlLine(
                                                    color: color,
                                                    strokeWidth: 1.5,
                                                  ),
                                                  FlDotData(
                                                    show: true,
                                                    getDotPainter:
                                                        (
                                                          spot,
                                                          percent,
                                                          barData,
                                                          index,
                                                        ) {
                                                          return FlDotCirclePainter(
                                                            radius: 8,
                                                            color: color,
                                                            strokeWidth: 1,
                                                            strokeColor:
                                                                Colors.white,
                                                          );
                                                        },
                                                  ),
                                                );
                                              }).toList();
                                            },
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: points
                                              .map(
                                                (p) => FlSpot(
                                                  p.date.millisecondsSinceEpoch
                                                      .toDouble(),
                                                  p.price,
                                                ),
                                              )
                                              .toList(),
                                          color: color,
                                          barWidth: 2,
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
                          const SizedBox(height: 16),

                          // Interval Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: ['1D', '1W', '1M', '1Y', 'All', 'Custom']
                                .map((interval) {
                                  final isSelected =
                                      _selectedInterval == interval;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedInterval = interval;
                                        if (interval != 'Custom') {
                                          _customStartDate = null;
                                          _customEndDate = null;
                                          _fetchDataForInterval();
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? color
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        interval,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                          const SizedBox(height: 24),

                          // Key Statistics Title
                          Text(
                            "Key Statistics",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Statistics Grid
                          GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildStatItem(
                                'Market Cap',
                                _formatMarketCap(_stock.marketCap),
                                theme,
                              ),
                              _buildStatItem(
                                'P/E Ratio',
                                _stock.peRatio?.toStringAsFixed(2) ?? 'N/A',
                                theme,
                              ),
                              _buildStatItem(
                                'Div Yield',
                                _stock.dividendYield != null
                                    ? '${_stock.dividendYield!.toStringAsFixed(2)}%'
                                    : 'N/A',
                                theme,
                              ),
                              _buildStatItem(
                                'EPS',
                                _stock.earningsPerShare?.toStringAsFixed(2) ??
                                    'N/A',
                                theme,
                              ),
                              _buildStatItem(
                                'Employees',
                                _stock.employees?.toString() ?? 'N/A',
                                theme,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // --- EARNINGS TAB ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: EarningsChart(
                      earnings: _earningsHistory,
                      isLoading: _isEarningsLoading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton(
    String label,
    DateTime? date,
    VoidCallback onTap,
    ThemeData theme,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
          color: date != null ? color.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              date != null ? DateFormat('MMM d, y').format(date) : label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    if (_selectedInterval == '1D') {
      return DateFormat('HH:mm').format(date);
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}

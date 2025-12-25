import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../data/stock_repository.dart';
import '../data/market_data_service.dart';
import '../domain/price_point.dart';
import '../domain/stock.dart';
import '../domain/earnings_point.dart';
import 'earnings_chart.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../data/market_data_service.dart';

class StockDetailBottomSheet extends StatefulWidget {
  final Stock stock;

  const StockDetailBottomSheet({super.key, required this.stock});

  @override
  State<StockDetailBottomSheet> createState() => _StockDetailBottomSheetState();
}

class _StockDetailBottomSheetState extends State<StockDetailBottomSheet>
    with SingleTickerProviderStateMixin {
  late final StockRepository _repository;
  late final MarketDataService _marketDataService;
  late final StreamSubscription _subscription; // Manage subscription manually
  Timer? _refreshTimer;
  List<PricePoint> _history = [];
  late Stock _stock; // Local mutable stock to hold details
  bool _isLoading = true;
  String _selectedInterval = '1D'; // Default to 1D
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  PricePoint? _selectedPoint;

  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Initialize Services from Provider
    _repository = context.read<StockRepository>();
    _marketDataService = context.read<MarketDataService>();

    // Ensure connected (idempotent if already connected)
    _marketDataService.connect();

    // Subscribe to updates
    _subscription = _marketDataService.updates.listen(_onStockUpdate);

    _loadData();

    // Start periodic refresh for 1D graph (every 1 minute)
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && _selectedInterval == '1D') {
        _fetchDataForInterval();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    _subscription.cancel(); // Cancel subscription, do NOT dispose service
    super.dispose();
  }

  void _onStockUpdate(Map<String, dynamic> event) {
    if (event['sym'] == _stock.symbol) {
      final price = (event['c'] as num?)?.toDouble();
      if (price != null && mounted) {
        setState(() {
          // Update current price
          // We keep previousClose constant to calculate change correctly against the day's start
          final prevClose = _stock.previousClose ?? _stock.price;
          final change = price - prevClose;
          final changePercent = (prevClose != 0)
              ? (change / prevClose) * 100
              : 0.0;

          _stock = _stock.copyWith(
            price: price,
            change: change,
            changePercent: changePercent,
          );
        });
      }
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      if (_currentTabIndex == 1 &&
          _earningsHistory.isEmpty &&
          !_isEarningsLoading) {
        _fetchEarnings();
      }
    }
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

          // Subscribe after loading initial details
          _marketDataService.subscribe([_stock.symbol]);
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
  List<PricePoint>? _monthlyHistory;
  List<EarningsPoint> _earningsHistory = [];
  bool _isEarningsLoading = false;
  String _earningsFrequency = 'quarterly'; // 'quarterly', 'annual'
  String _earningsMetric = 'EPS'; // 'EPS', 'Revenue'

  Future<void> _fetchDataForInterval() async {
    if (_selectedInterval == '1D') {
      // For 1D, we always refresh to get latest delayed candles
      // setState(() => _isLoading = true); // Optional: don't show loading on refresh
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
    } else if (_selectedInterval == '1M' && _monthlyHistory == null) {
      setState(() => _isLoading = true);
      final data = await _repository.getMonthlyHistory(_stock.symbol);
      if (mounted) {
        setState(() {
          _monthlyHistory = data;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchEarnings() async {
    setState(() => _isEarningsLoading = true);
    final data = await _repository.getEarningsHistory(
      _stock.symbol,
      frequency: _earningsFrequency,
    );
    if (mounted) {
      setState(() {
        _earningsHistory = data;
        _isEarningsLoading = false;
      });
    }
  }

  List<PricePoint> get _filteredHistory {
    if (_selectedInterval == '1D') {
      if (_intradayHistory != null && _intradayHistory!.isNotEmpty) {
        final lastPointDate = _intradayHistory!.last.date;
        final startOfDay = DateTime(
          lastPointDate.year,
          lastPointDate.month,
          lastPointDate.day,
        );
        return _intradayHistory!
            .where((p) => p.date.isAfter(startOfDay))
            .toList();
      }
      return [];
    }

    if (_selectedInterval == '1W') {
      if (_weeklyHistory != null && _weeklyHistory!.isNotEmpty) {
        return _weeklyHistory!;
      }
    }

    if (_selectedInterval == '1M') {
      if (_monthlyHistory != null && _monthlyHistory!.isNotEmpty) {
        return _monthlyHistory!;
      }
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
        cutoff = DateTime(1970);
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
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
                ),
                Flexible(
                  flex: 1,
                  child: Column(
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
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorColor: color,
            labelColor: color,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: l10n.overview),
              Tab(text: l10n.earnings),
            ],
          ),

          const SizedBox(height: 16),

          // Content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: _currentTabIndex == 0
                ? _buildOverviewTab(theme, color, points, l10n)
                : _buildEarningsTab(theme, color, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab(
    ThemeData theme,
    Color color,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleOption(
                      l10n.eps,
                      _earningsMetric == 'EPS',
                      () => setState(() {
                        _earningsMetric = 'EPS';
                      }),
                      theme,
                      color,
                    ),
                    _buildToggleOption(
                      l10n.revenue,
                      _earningsMetric == 'Revenue',
                      () => setState(() {
                        _earningsMetric = 'Revenue';
                      }),
                      theme,
                      color,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleOption(
                      l10n.quarterly,
                      _earningsFrequency == 'quarterly',
                      () {
                        if (_earningsFrequency != 'quarterly') {
                          setState(() {
                            _earningsFrequency = 'quarterly';
                          });
                          _fetchEarnings();
                        }
                      },
                      theme,
                      color,
                    ),
                    _buildToggleOption(
                      l10n.annual,
                      _earningsFrequency == 'annual',
                      () {
                        if (_earningsFrequency != 'annual') {
                          setState(() {
                            _earningsFrequency = 'annual';
                          });
                          _fetchEarnings();
                        }
                      },
                      theme,
                      color,
                    ),
                  ],
                ),
              ),
            ],
          ),

          EarningsChart(
            earnings: _earningsHistory,
            isLoading: _isEarningsLoading,
            metric: _earningsMetric,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    ThemeData theme,
    Color color,
    List<PricePoint> points,
    AppLocalizations l10n,
  ) {
    // Determine dynamic axes for 1D to support any timezone (e.g. CET)
    // We assume the market session is 6.5 hours (standard US).
    // If we have data, we anchor 'minX' to the first point (Open).
    // 'maxX' is Open + 6.5 hours.
    // If no data, we fallback to a default 9:30-16:00 Local assumption or just wait for data.

    // Determine dynamic axes
    double? minX;
    double? maxX;
    double? interval;

    // For 1D, we use Time-based X-axis (millisecondsSinceEpoch) to show "filling from left".
    // For others (1M, 1W), we use Index-based X-axis (0, 1, 2...) to "skip" weekends/closed hours.
    final isIntraday = _selectedInterval == '1D';

    if (isIntraday) {
      if (points.isNotEmpty) {
        // Use dynamic scaling based on data
        minX = points.first.date.millisecondsSinceEpoch.toDouble();
        maxX = points.last.date.millisecondsSinceEpoch.toDouble();

        // Dynamic interval: target around 4-6 labels
        if (maxX! > minX!) {
          interval = (maxX! - minX!) / 4;
        } else {
          interval = 3600000; // 1 hour fallback
        }
      } else {
        // Default placeholder
        final now = DateTime.now();
        final open = DateTime(now.year, now.month, now.day, 9, 30);
        minX = open.millisecondsSinceEpoch.toDouble();
        maxX = open
            .add(const Duration(hours: 6, minutes: 30))
            .millisecondsSinceEpoch
            .toDouble();
      }
    } else {
      // Index based
      if (points.isNotEmpty) {
        minX = 0;
        maxX = (points.length - 1).toDouble();

        // Calculate interval to show ~5 labels
        interval = (points.length / 5).floorToDouble();
        if (interval == 0) interval = 1;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

          SizedBox(
            height: 200,
            child: _isLoading && _history.isEmpty
                ? const Center(child: CircularProgressIndicator())
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
                      minX: minX,
                      maxX: maxX,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: null,
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            interval: interval,
                            // Hide min/max for 1D as requested
                            minIncluded: !isIntraday,
                            maxIncluded: !isIntraday,
                            getTitlesWidget: (value, meta) {
                              DateTime date;
                              if (isIntraday) {
                                date = DateTime.fromMillisecondsSinceEpoch(
                                  value.toInt(),
                                );
                              } else {
                                final index = value.toInt();
                                if (index < 0 || index >= points.length) {
                                  return const SizedBox();
                                }
                                date = points[index].date;
                              }

                              if (isIntraday) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat('HH:mm').format(date),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }

                              if (value == meta.min || value == meta.max) {
                                String formatted;
                                if (_selectedInterval == '1W') {
                                  formatted = DateFormat('EEE').format(date);
                                } else if (_selectedInterval == '1M') {
                                  formatted = DateFormat('MMM d').format(date);
                                } else {
                                  formatted = DateFormat('MMM yy').format(date);
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
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
                                padding: const EdgeInsets.only(left: 8),
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
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
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
                                  touchResponse.lineBarSpots == null ||
                                  touchResponse.lineBarSpots!.isEmpty) {
                                setState(() {
                                  _selectedPoint = null;
                                });
                                return;
                              }

                              final spot = touchResponse.lineBarSpots!.first;
                              final val = spot.x;

                              if (isIntraday) {
                                final date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                      val.toInt(),
                                    );
                                setState(() {
                                  _selectedPoint = PricePoint(
                                    date: date,
                                    price: spot.y,
                                  );
                                });
                              } else {
                                final index = val.toInt();
                                if (index >= 0 && index < points.length) {
                                  setState(() {
                                    _selectedPoint = points[index];
                                  });
                                }
                              }
                            },
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedBarSpots) {
                            return touchedBarSpots.map((_) => null).toList();
                          },
                        ),
                        getTouchedSpotIndicator:
                            (LineChartBarData barData, List<int> spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(color: color, strokeWidth: 1.5),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 8,
                                            color: color,
                                            strokeWidth: 1,
                                            strokeColor:
                                                AppTheme.backgroundDark,
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
                              .asMap()
                              .entries
                              .map(
                                (entry) => FlSpot(
                                  isIntraday
                                      ? entry.value.date.millisecondsSinceEpoch
                                            .toDouble()
                                      : entry.key.toDouble(),
                                  entry.value.price,
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['1D', '1W', '1M', '1Y', 'All', 'Custom'].map((interval) {
              final isSelected = _selectedInterval == interval;
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
                    vertical: 5,
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

          Text(
            l10n.keyStatistics,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatItem(
                l10n.marketCap,
                _formatMarketCap(_stock.marketCap),
                theme,
              ),
              _buildStatItem(
                l10n.peRatio,
                _stock.peRatio?.toStringAsFixed(2) ?? 'N/A',
                theme,
              ),
              _buildStatItem(
                l10n.divYield,
                _stock.dividendYield != null
                    ? '${_stock.dividendYield!.toStringAsFixed(2)}%'
                    : 'N/A',
                theme,
              ),
              _buildStatItem(
                l10n.eps,
                _stock.earningsPerShare?.toStringAsFixed(2) ?? 'N/A',
                theme,
              ),
              _buildStatItem(
                l10n.employees,
                _stock.employees?.toString() ?? 'N/A',
                theme,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
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

  Widget _buildToggleOption(
    String text,
    bool isSelected,
    VoidCallback onTap,
    ThemeData theme,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? color : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(
    String text,
    DateTime? date,
    VoidCallback onTap,
    ThemeData theme,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.canvasColor,
            foregroundColor: color,
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            date != null ? DateFormat('MMM d, y').format(date) : 'Select',
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, HH:mm').format(date);
  }
}

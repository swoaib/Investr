import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../data/stock_repository.dart';
// import '../data/market_data_service.dart'; // Unused import
import '../domain/price_point.dart';
import '../domain/stock.dart';
import '../domain/earnings_point.dart';
import 'earnings_chart.dart';
import 'package:investr/src/features/market_data/presentation/stock_list_controller.dart';
import '../../alerts/presentation/alert_dialog.dart';
import '../../../shared/widgets/sliding_segmented_control.dart';

enum StockDetailView { overview, earnings }

class StockDetailBottomSheet extends StatefulWidget {
  final Stock stock;

  const StockDetailBottomSheet({super.key, required this.stock});

  @override
  State<StockDetailBottomSheet> createState() => _StockDetailBottomSheetState();
}

class _StockDetailBottomSheetState extends State<StockDetailBottomSheet> {
  late final StockRepository _repository;
  // late final MarketDataService _marketDataService; // Removed WebSocket
  // late final StreamSubscription _subscription; // Removed WebSocket
  Timer? _refreshTimer;
  List<PricePoint> _history = [];
  late Stock _stock; // Local mutable stock to hold details
  bool _isLoading = true;
  String _selectedInterval = '1D'; // Default to 1D
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  PricePoint? _selectedPoint;

  Set<StockDetailView> _selectedView = {StockDetailView.overview};

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    // _tabController = TabController(length: 2, vsync: this);
    // _tabController.addListener(_handleTabSelection);

    // Initialize Services from Provider
    _repository = context.read<StockRepository>();
    // _marketDataService = context.read<MarketDataService>(); // Removed WebSocket

    // Ensure connected (idempotent if already connected)
    // _marketDataService.connect(); // Removed WebSocket

    // Subscribe to updates
    // _subscription = _marketDataService.updates.listen(_onStockUpdate); // Removed WebSocket

    _loadData();

    // Start periodic refresh for 1D graph (every 30 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _selectedInterval == '1D') {
        _fetchDataForInterval();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    // _tabController.dispose();
    // _subscription.cancel(); // Removed WebSocket
    super.dispose();
  }

  // void _onStockUpdate(Map<String, dynamic> event) { ... } // Removed WebSocket

  void _handleViewSelection(Set<StockDetailView> newSelection) {
    setState(() {
      _selectedView = newSelection;
    });
    if (_selectedView.contains(StockDetailView.earnings) &&
        _earningsHistory.isEmpty &&
        !_isEarningsLoading) {
      _fetchEarnings();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch history, details, intraday, AND fresh quote (for accurate PrevClose)
      final historyFuture = _repository.getStockHistory(widget.stock.symbol);
      final detailsFuture = _repository.getStockDetails(widget.stock);
      final intradayFuture = _repository.getIntradayHistory(
        widget.stock.symbol,
      );
      final quoteFuture = _repository.getStock(widget.stock.symbol);
      final metricsFuture = _repository.getKeyMetrics(widget.stock);

      final results = await Future.wait([
        historyFuture,
        detailsFuture,
        intradayFuture,
        quoteFuture,
        metricsFuture,
      ]);

      if (mounted) {
        setState(() {
          _history = results[0] as List<PricePoint>;

          // Cascading merge: Start with Initial -> Details -> Metrics -> Quote
          // 1. Details (Description, Employees, basic Market Cap)
          var loadedStock = results[1] as Stock;
          _intradayHistory = results[2] as List<PricePoint>;

          // 2. Metrics (PE, DivYield, EPS)
          final metricsStock = results[4] as Stock;
          loadedStock = loadedStock.copyWith(
            peRatio: metricsStock.peRatio,
            dividendYield: metricsStock.dividendYield,
            earningsPerShare: metricsStock.earningsPerShare,
          );

          // 3. Fresh Quote (Price, PrevClose, High/Low, Change%, overwrite MarketCap with live)
          final quoteStock = results[3] as Stock?;

          if (quoteStock != null) {
            loadedStock = loadedStock.copyWith(
              price: quoteStock.price,
              previousClose: quoteStock.previousClose,
              change: quoteStock.change,
              changePercent: quoteStock.changePercent,
              marketCap: quoteStock
                  .marketCap, // Quote is usually more real-time than profile
              high52Week: quoteStock.high52Week,
              low52Week: quoteStock.low52Week,
              exchange: quoteStock.exchange,
              currency: quoteStock.currency,
            );
          }

          _stock = loadedStock;
          _isLoading = false;

          // Subscribe after loading initial details
          // _marketDataService.subscribe([_stock.symbol]); // Removed WebSocket
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
  String _earningsFrequency = 'annual'; // Defaults to Annual
  String _earningsMetric = 'Revenue'; // Defaults to Revenue

  Future<void> _fetchDataForInterval() async {
    if (_selectedInterval == '1D') {
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
        return _repository.filterForMarketHours(_intradayHistory!);
      }
      return [];
    }

    if (_selectedInterval == '1W') {
      return _weeklyHistory ?? [];
    }

    if (_selectedInterval == '1M') {
      return _monthlyHistory ?? [];
    }

    if (_history.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoff;

    switch (_selectedInterval) {
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

  String _formatDate(DateTime date) {
    if (_selectedInterval == '1D') {
      // Since 1D now shows a "Daily Trend" of 30 days, we show MMM d format
      return DateFormat('MMM d').format(date);
    } else if (_selectedInterval == '1W' || _selectedInterval == '1M') {
      return DateFormat('MMM d, yyyy').format(date);
    } else {
      return DateFormat('MMM yyyy').format(date);
    }
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
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stock.symbol.startsWith('^')
                            ? _stock.companyName
                            : _stock.symbol,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _stock.symbol.startsWith('^')
                            ? _stock.symbol
                            : _stock.companyName,
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedPoint != null
                                ? currencyFormat.format(_selectedPoint!.price)
                                : currencyFormat.format(_stock.price),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

          const SizedBox(height: 16),

          // Control Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SlidingSegmentedControl<StockDetailView>(
                  groupValue: _selectedView.first,
                  children: {
                    StockDetailView.overview: l10n.overview,
                    StockDetailView.earnings: l10n.earnings,
                  },
                  onValueChanged: (value) => _handleViewSelection({value}),
                ),
                const Spacer(),
                // Alert Button
                IconButton.outlined(
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SetAlertDialog(
                        symbol: _stock.symbol,
                        currentPrice: _stock.price,
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_outlined, size: 20),
                  tooltip: 'Set Price Alert',
                ),
                const SizedBox(width: 8),
                // Watchlist Button
                Consumer<StockListController>(
                  builder: (context, controller, child) {
                    final isInWatchlist = controller.isInWatchlist(
                      _stock.symbol,
                    );
                    return IconButton.outlined(
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        side: BorderSide(
                          color: isInWatchlist
                              ? theme.colorScheme.primary.withValues(alpha: 0.5)
                              : Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                      onPressed: () {
                        if (isInWatchlist) {
                          controller.removeFromWatchlist(_stock);
                        } else {
                          controller.addToWatchlist(_stock);
                        }
                      },
                      icon: Icon(
                        isInWatchlist ? Icons.check : Icons.add,
                        size: 20,
                        color: isInWatchlist ? theme.colorScheme.primary : null,
                      ),
                      tooltip: isInWatchlist
                          ? 'Remove from Watchlist'
                          : 'Add to Watchlist',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: _selectedView.contains(StockDetailView.overview)
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
              // Metric Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _earningsMetric,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.iconTheme.color,
                      size: 16,
                    ),
                    isDense: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    dropdownColor: theme.cardColor,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _earningsMetric = newValue;
                        });
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'Revenue',
                        child: Text(l10n.revenue),
                      ),
                      DropdownMenuItem(value: 'EPS', child: Text(l10n.eps)),
                      const DropdownMenuItem(
                        value: 'Net Income',
                        child: Text('Net Income'),
                      ),
                      const DropdownMenuItem(
                        value: 'Gross Profit',
                        child: Text('Gross Profit'),
                      ),
                      const DropdownMenuItem(
                        value: 'Operating Income',
                        child: Text('Operating Income'),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Frequency Toggle
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
    // UPDATE: Since we are falling back to Daily data for "Intraday" (due to API restrictions),
    // we should use Index-based for 1D as well to show the trend of the last 30 days properly.
    // If we tried to plot 30 days on a 6.5 hour axis it would break.
    // So we treat everything as Index-Based for now.

    final isIntraday = _selectedInterval == '1D';

    if (points.isNotEmpty) {
      minX = 0;
      if (isIntraday) {
        final lastDate = points.last.date;
        final now = DateTime.now();
        final isToday =
            lastDate.year == now.year &&
            lastDate.month == now.month &&
            lastDate.day == now.day;

        // If today, project full day (min 78 intervals).
        // This ensures the graph grows from left to right for ALL markets.
        if (isToday) {
          double count = (points.length - 1).toDouble();
          maxX = count < 78.0 ? 78.0 : count;
        } else {
          maxX = (points.length - 1).toDouble();
        }
      } else {
        maxX = (points.length - 1).toDouble();
      }
    }

    if (points.isNotEmpty) {
      // Calculate interval based on the range (maxX) to ensure consistent label spacing
      // regardless of how many data points we currently have.
      double range = (maxX ?? 0) - (minX ?? 0);
      if (range == 0) range = 1; // Prevent division by zero if single point

      interval = (range / 5).floorToDouble();
      if (interval == 0) interval = 1;
    }

    // Determine Y-Axis with padding
    double? minY;
    double? maxY;
    if (points.isNotEmpty) {
      final prices = points.map((p) => p.price);
      var minPrice = prices.reduce((a, b) => a < b ? a : b);
      var maxPrice = prices.reduce((a, b) => a > b ? a : b);

      if (isIntraday && _stock.previousClose != null) {
        if (_stock.previousClose! < minPrice) minPrice = _stock.previousClose!;
        if (_stock.previousClose! > maxPrice) maxPrice = _stock.previousClose!;
      }

      final range = maxPrice - minPrice;
      final padding = range == 0 ? minPrice * 0.02 : range * 0.05; // 5% padding

      minY = minPrice - padding;
      maxY = maxPrice + padding;
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
            child: _isLoading
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
                      minY: minY,
                      maxY: maxY,
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          if (isIntraday && _stock.previousClose != null)
                            HorizontalLine(
                              y: _stock.previousClose!,
                              color: Colors.grey.withValues(alpha: 0.5),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.only(
                                  right: 5,
                                  bottom: 5,
                                ),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                labelResolver: (line) => 'Prev Close',
                              ),
                            ),
                        ],
                      ),
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
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) {
                                return const SizedBox();
                              }
                              date = points[index].date;

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
                                  // Bottom half: Native line
                                  FlLine(
                                    color: color,
                                    strokeWidth: 1.5,
                                    dashArray: [1, 1],
                                  ),
                                  // Top half & Dot: Custom painter
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return _ChartTouchDotPainter(
                                            color: color,
                                            context: context,
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
                                  entry.key.toDouble(),
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
                'Prev Close',
                _stock.previousClose?.toStringAsFixed(2) ?? 'N/A',
                theme,
              ),
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
}

class _ChartTouchDotPainter extends FlDotPainter {
  final Color color;
  final BuildContext context;

  _ChartTouchDotPainter({required this.color, required this.context});

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    // 1. Draw the "Top Half" of the line (from top of chart to the dot)
    // We use a dashed line to match the bottom style
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 1.0;
    const dashSpace = 1.0;

    // Start from the dot (offsetInCanvas.dy) and go UP to 0
    double currentY = offsetInCanvas.dy;

    while (currentY > 0) {
      final endY = max(0.0, currentY - dashWidth);
      canvas.drawLine(
        Offset(offsetInCanvas.dx, currentY),
        Offset(offsetInCanvas.dx, endY),
        paint,
      );
      currentY -= (dashWidth + dashSpace);
    }

    // 2. Draw the Dot (Circle)
    // We can reuse FlDotCirclePainter logic or simple draw
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Main dot
    canvas.drawCircle(offsetInCanvas, 8, dotPaint..color = color);

    // Stroke/Border
    final borderPaint = Paint()
      ..color = AppTheme.backgroundDark
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(offsetInCanvas, 8, borderPaint);
  }

  @override
  Size getSize(FlSpot spot) => const Size(16, 16);

  @override
  List<Object?> get props => [color, context];

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    return b;
  }

  @override
  Color get mainColor => color;
}

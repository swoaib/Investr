import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:investr/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../shared/currency/currency_controller.dart';
import '../../../shared/currency/data/currency_repository.dart';
import '../../../shared/market/market_schedule_service.dart';
import '../../../shared/settings/settings_controller.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../../../shared/widgets/sliding_segmented_control.dart';
import '../../../shared/widgets/stock_logo.dart';
import '../../currency/domain/currency_conversion.dart';
import '../../currency/presentation/currency_add_sheet.dart';
import '../../currency/presentation/currency_list_widget.dart';
import '../domain/stock.dart';
import 'stock_detail_bottom_sheet.dart';
import 'stock_list_controller.dart';
import 'widgets/stock_ticker.dart';

enum _MarketView { stocks, currency }

class StockListScreen extends StatelessWidget {
  const StockListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StockListView();
  }
}

class _StockListView extends StatefulWidget {
  const _StockListView();

  @override
  State<_StockListView> createState() => _StockListViewState();
}

class _StockListViewState extends State<_StockListView> {
  final CurrencyRepository _currencyRepo = CurrencyRepository();
  Timer? _currencyPollingTimer;
  late _MarketView _currentView;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>();
    _currentView = settings.defaultLandingPage == 'currency'
        ? _MarketView.currency
        : _MarketView.stocks;

    if (_currentView == _MarketView.currency) {
      _startCurrencyPolling();
    }
  }

  @override
  void dispose() {
    _currencyPollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StockListController>();
    final settingsController = context.watch<SettingsController>();
    final currencyController = context.watch<CurrencyController>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.screenPaddingHorizontal,
                AppTheme.screenPaddingVertical,
                AppTheme.screenPaddingHorizontal,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentView == _MarketView.stocks
                          ? l10n.stockMarketTitle
                          : 'Currency',
                      style: theme.textTheme.headlineLarge,
                    ),
                    SizedBox(
                      width: 90,
                      child: SlidingSegmentedControl<_MarketView>(
                        groupValue: _currentView,
                        children: const {
                          _MarketView.stocks: Icon(Icons.show_chart),
                          _MarketView.currency: Icon(
                            Icons.attach_money_rounded,
                          ),
                        },
                        onValueChanged: (value) {
                          setState(() {
                            _currentView = value;
                          });
                          if (value == _MarketView.currency) {
                            _startCurrencyPolling();
                          } else {
                            _currencyPollingTimer?.cancel();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (settingsController.showStockTicker &&
                controller.stocks.isNotEmpty) ...[
              StockTicker(stocks: controller.stocks),
              const SizedBox(height: 8),
            ],

            Expanded(
              child: _currentView == _MarketView.stocks
                  ? (controller.isLoading
                        ? _buildShimmerLoading(context)
                        : controller.error != null
                        ? Center(child: Text(controller.error!))
                        : controller.isSearching
                        ? _buildSearchResults(controller, l10n)
                        : _buildWatchlist(controller, l10n))
                  : CurrencyListWidget(
                      conversions: currencyController.savedConversions,
                      lastUpdated: currencyController.lastUpdated,
                      isLoading: currencyController.isLoading,
                      onRemove: (conversion) {
                        context.read<CurrencyController>().removeConversion(
                          conversion,
                        );
                      },
                      onAddCurrency: () async {
                        final result =
                            await showModalBottomSheet<CurrencyConversion>(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => const CurrencyAddSheet(),
                            );

                        if (result == null || !context.mounted) return;

                        var rate = await _currencyRepo.getExchangeRate(
                          result.baseCurrency,
                          result.targetCurrency,
                        );

                        var viaUSD = false;

                        // Smart Fallback Logic
                        if (rate == null) {
                          final rateToUSD = await _currencyRepo.getExchangeRate(
                            result.baseCurrency,
                            'USD',
                          );
                          final rateFromUSD = await _currencyRepo
                              .getExchangeRate('USD', result.targetCurrency);

                          if (rateToUSD != null && rateFromUSD != null) {
                            rate = rateToUSD * rateFromUSD;
                            viaUSD = true;
                          }
                        }

                        if (!context.mounted) return;

                        if (rate != null) {
                          if (viaUSD) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.conversionViaUSD(
                                    result.baseCurrency,
                                    result.targetCurrency,
                                  ),
                                ),
                              ),
                            );
                          }

                          final currencyController = context
                              .read<CurrencyController>();
                          await currencyController.addConversion(
                            CurrencyConversion.create(
                              baseCurrency: result.baseCurrency,
                              targetCurrency: result.targetCurrency,
                              rate: rate,
                              amount: result.amount,
                              viaUSD: viaUSD,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.errorFetchingData)),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlist(
    StockListController controller,
    AppLocalizations l10n,
  ) {
    if (controller.stocks.isEmpty) {
      return Center(child: Text(l10n.noStocksInWatchlist));
    }
    return ReorderableListView.builder(
      padding: EdgeInsets.only(
        bottom: CustomBottomNavigationBar.contentBottomPadding,
      ),
      itemCount: controller.stocks.length,
      onReorder: (oldIndex, newIndex) {
        controller.reorderStocks(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final stock = controller.stocks[index];
        return Column(
          key: Key(stock.symbol),
          children: [
            Dismissible(
              key: Key('dismiss_${stock.symbol}'),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                controller.removeFromWatchlist(stock);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${stock.symbol} ${l10n.removedFromWatchlist}',
                    ),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(
                      AppTheme.screenPaddingHorizontal,
                    ),
                    action: SnackBarAction(
                      label: l10n.undo,
                      onPressed: () {
                        controller.addToWatchlist(stock, insertAt: index);
                      },
                    ),
                  ),
                );
              },
              child: _StockListItem(stock: stock),
            ),
            if (index < controller.stocks.length - 1)
              const Divider(
                height: 1,
                indent: AppTheme.screenPaddingHorizontal,
                endIndent: AppTheme.screenPaddingHorizontal,
              ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(
    StockListController controller,
    AppLocalizations l10n,
  ) {
    if (controller.searchResults.isEmpty) {
      return Center(child: Text(l10n.noResultsFound));
    }
    return ListView.separated(
      padding: EdgeInsets.only(
        bottom: CustomBottomNavigationBar.contentBottomPadding,
      ),
      itemCount: controller.searchResults.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: AppTheme.screenPaddingHorizontal,
        endIndent: AppTheme.screenPaddingHorizontal,
      ),
      itemBuilder: (context, index) {
        final stock = controller.searchResults[index];
        return _SearchResultItem(
          stock: stock,
          isInWatchlist: controller.isInWatchlist(stock.symbol),
          onAddToWatchlist: () {
            controller.addToWatchlist(stock);
          },
        );
      },
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.only(
          bottom: CustomBottomNavigationBar.contentBottomPadding,
        ),
        itemCount: 10,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          indent: AppTheme.screenPaddingHorizontal,
          endIndent: AppTheme.screenPaddingHorizontal,
        ),
        itemBuilder: (_, _) => Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: AppTheme.screenPaddingHorizontal,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 40, height: 16, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 12, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(width: 60, height: 16, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 40, height: 12, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCurrencyPolling() {
    _currencyPollingTimer?.cancel();

    // Immediate refresh
    context.read<CurrencyController>().refreshSavedConversions();

    _currencyPollingTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted && _currentView == _MarketView.currency) {
        context.read<CurrencyController>().refreshSavedConversions();
      }
    });
  }
}

class _StockListItem extends StatelessWidget {
  final Stock stock;

  const _StockListItem({required this.stock});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final currencyController = context.watch<CurrencyController>();
    final currencySymbol = currencyController.currencySymbol;
    final rate = currencyController.exchangeRate;

    final isIndex = stock.isIndex;
    final currencyFormat = isIndex
        ? NumberFormat.currency(symbol: '')
        : currencySymbol == 'kr'
        ? NumberFormat.currency(symbol: '$currencySymbol ')
        : NumberFormat.currency(symbol: currencySymbol);
    final isPositive = stock.isPositive;
    final color = isPositive ? AppTheme.primaryGreen : Colors.red;

    // Convert values
    final effectiveRate = isIndex ? 1.0 : rate;
    final displayPrice = stock.price * effectiveRate;

    // Calculate Sparkline Y-Axis Range ensuring Previous Close is visible
    double? minY;
    double? maxY;
    if (stock.sparklineData != null && stock.sparklineData!.isNotEmpty) {
      final prices = stock.sparklineData!.map((p) => p.price);
      var minPrice = prices.reduce((a, b) => a < b ? a : b);
      var maxPrice = prices.reduce((a, b) => a > b ? a : b);

      if (stock.previousClose != null) {
        if (stock.previousClose! < minPrice) minPrice = stock.previousClose!;
        if (stock.previousClose! > maxPrice) maxPrice = stock.previousClose!;
      }

      final range = maxPrice - minPrice;
      final padding = range == 0 ? minPrice * 0.02 : range * 0.05; // 5% padding
      minY = minPrice - padding;
      maxY = maxPrice + padding;
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => StockDetailBottomSheet(stock: stock),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: AppTheme.screenPaddingHorizontal,
        ),
        color: Colors.transparent, // Ensures hit test works on empty space
        child: Row(
          children: [
            // Logo
            if (settingsController.showStockLogos) ...[
              StockLogo(
                url: stock.imageUrl,
                symbol: stock.symbol,
                countryCode: stock.country,
                exchange: stock.exchange,
                currency: stock.currency,
              ),
              const SizedBox(width: 12),
            ],
            // Symbol and Name
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol.startsWith('^')
                        ? stock.companyName
                        : stock.symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    stock.symbol.startsWith('^')
                        ? stock.symbol
                        : stock.companyName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            if (stock.sparklineData != null && stock.sparklineData!.isNotEmpty)
              SizedBox(
                width: 60,
                height: 30,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (() {
                      final points = stock.sparklineData!;
                      final lastDate = points.last.date;
                      final now = DateTime.now();
                      final isToday =
                          lastDate.year == now.year &&
                          lastDate.month == now.month &&
                          lastDate.day == now.day;

                      // Standardize scaling based on market schedule
                      if (isToday) {
                        final schedule = MarketScheduleService.getSchedule(
                          stock.symbol,
                        );
                        final expectedPoints = schedule.expectedPoints(
                          5,
                        ); // 5-min intervals

                        final count = (points.length - 1).toDouble();
                        return count < expectedPoints ? expectedPoints : count;
                      }
                      return (points.length - 1).toDouble();
                    })(),
                    minY: minY,
                    maxY: maxY,
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: const LineTouchData(enabled: false),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        if (stock.previousClose != null)
                          HorizontalLine(
                            y: stock.previousClose!,
                            color: Colors.grey.withValues(alpha: 0.5),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                      ],
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: stock.sparklineData!
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value.price))
                            .toList(),
                        isCurved: true,
                        color: color,
                        barWidth: 1.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(width: 16),
            // Price and Change
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(displayPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
}

/// Widget for displaying a search result with an add button
class _SearchResultItem extends StatelessWidget {
  final Stock stock;
  final bool isInWatchlist;
  final VoidCallback onAddToWatchlist;

  const _SearchResultItem({
    required this.stock,
    required this.isInWatchlist,
    required this.onAddToWatchlist,
  });

  @override
  Widget build(BuildContext context) {
    final currencyController = context.watch<CurrencyController>();
    final currencySymbol = currencyController.currencySymbol;
    final rate = currencyController.exchangeRate;

    final currencyFormat = NumberFormat.currency(
      symbol: stock.isIndex ? '' : currencySymbol,
    );
    final isPositive = stock.isPositive;
    final color = isPositive ? AppTheme.primaryGreen : Colors.red;

    // Convert values
    // Convert values
    final effectiveRate = stock.isIndex ? 1.0 : rate;
    final displayPrice = stock.price * effectiveRate;
    final settingsController = context.watch<SettingsController>();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => StockDetailBottomSheet(stock: stock),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: AppTheme.screenPaddingHorizontal,
        ),
        color: Colors.transparent, // Ensures hit test works on empty space
        child: Row(
          children: [
            // Logo
            if (settingsController.showStockLogos) ...[
              StockLogo(
                url: stock.imageUrl,
                symbol: stock.symbol,
                countryCode: stock.country,
              ),
              const SizedBox(width: 12),
            ],
            // Symbol and Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol.startsWith('^')
                        ? stock.companyName
                        : stock.symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    stock.symbol.startsWith('^')
                        ? stock.symbol
                        : stock.companyName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Price and Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(displayPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Add button
            IconButton(
              icon: Icon(
                isInWatchlist ? Icons.check_circle : Icons.add_circle_outline,
                color: isInWatchlist
                    ? AppTheme.primaryGreen
                    : AppTheme.textGrey,
              ),
              onPressed: isInWatchlist ? null : onAddToWatchlist,
            ),
          ],
        ),
      ),
    );
  }
}

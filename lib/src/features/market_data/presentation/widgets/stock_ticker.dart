import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/currency/currency_controller.dart';
import '../../../../shared/market/market_schedule_service.dart';
import '../../../../shared/settings/settings_controller.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/stock_logo.dart';
import '../../domain/stock.dart';

class StockTicker extends StatefulWidget {
  final List<Stock> stocks;
  final VoidCallback? onStockTap;

  const StockTicker({required this.stocks, super.key, this.onStockTap});

  @override
  State<StockTicker> createState() => _StockTickerState();
}

class _StockTickerState extends State<StockTicker> {
  late ScrollController _scrollController;
  Timer? _timer;
  static const double _scrollIncrement = 1.0; // Pixels per tick
  static const Duration _tickDuration = Duration(
    milliseconds: 30,
  ); // ~30fps smooth enough for ticker

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Start scrolling after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer?.cancel();
    _timer = Timer.periodic(_tickDuration, (timer) {
      if (!_scrollController.hasClients) return;

      // Infinite scroll logic would basically be just keep adding to offset
      // Since we use infinite list builder, we can just scroll forever.
      // However, double capacity is limited. Resetting at very large numbers might be needed
      // but for a user session, it takes years to reach overflow with double.

      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent) {
        // Should not happen with infinite null count builder, but if we used limited...
        // We will use a large item count in builder.
      }

      _scrollController.jumpTo(_scrollController.offset + _scrollIncrement);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stocks.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 60,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics:
            const NeverScrollableScrollPhysics(), // User can't manually scroll effectively if auto-scrolling
        itemBuilder: (context, index) {
          final stock = widget.stocks[index % widget.stocks.length];
          return _StockTickerItem(stock: stock);
        },
      ),
    );
  }
}

class _StockTickerItem extends StatelessWidget {
  final Stock stock;

  const _StockTickerItem({required this.stock});

  @override
  Widget build(BuildContext context) {
    final currencyController = context.watch<CurrencyController>();
    final settingsController = context.watch<SettingsController>();
    final currencySymbol = currencyController.currencySymbol;
    final rate = currencyController.exchangeRate;

    final isPositive = stock.isPositive;
    final color = isPositive ? AppTheme.primaryGreen : Colors.red;
    final displayPrice = stock.price * rate;

    final currencyFormat = NumberFormat.currency(
      symbol: stock.symbol.startsWith('^') ? '' : currencySymbol,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (settingsController.showStockLogos) ...[
            StockLogo(
              url: stock.imageUrl,
              symbol: stock.symbol,
              countryCode: stock.country,
              size: 32,
            ),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stock.symbol,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
          const SizedBox(width: 16),
          // Mini Sparkline
          if (stock.sparklineData != null && stock.sparklineData!.isNotEmpty)
            SizedBox(
              width: 50,
              height: 25,
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
                  minY: (() {
                    final prices = stock.sparklineData!.map((p) => p.price);
                    return prices.reduce((a, b) => a < b ? a : b);
                  })(),
                  maxY: (() {
                    final prices = stock.sparklineData!.map((p) => p.price);
                    return prices.reduce((a, b) => a > b ? a : b);
                  })(),
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
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
          Text(
            currencyFormat.format(displayPrice),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

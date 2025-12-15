import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../domain/stock.dart';
import 'stock_list_controller.dart';
import 'stock_detail_bottom_sheet.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<StockListController>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StockListController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
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
                child: Text(
                  'Stock Market',
                  style: theme.textTheme.headlineLarge,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search (e.g. AAPL)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty ||
                          controller.isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide clear button
                },
                onSubmitted: (value) {
                  controller.searchStock(value);
                },
              ),
            ),
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.error != null
                  ? Center(child: Text(controller.error!))
                  : controller.isSearching
                  ? _buildSearchResults(controller)
                  : _buildWatchlist(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlist(StockListController controller) {
    if (controller.stocks.isEmpty) {
      return const Center(child: Text('No stocks in watchlist'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.screenPaddingHorizontal,
      ),
      itemCount: controller.stocks.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final stock = controller.stocks[index];
        return _StockListItem(stock: stock);
      },
    );
  }

  Widget _buildSearchResults(StockListController controller) {
    if (controller.searchResults.isEmpty) {
      return const Center(child: Text('No results found'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.screenPaddingHorizontal,
      ),
      itemCount: controller.searchResults.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
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
}

class _StockListItem extends StatelessWidget {
  final Stock stock;

  const _StockListItem({required this.stock});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isPositive = stock.isPositive;
    final color = isPositive ? AppTheme.primaryGreen : Colors.red;

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
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.transparent, // Ensures hit test works on empty space
        child: Row(
          children: [
            // Symbol and Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    stock.companyName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Mini Sparkline Chart
            SizedBox(
              width: 60,
              height: 30,
              child:
                  stock.sparklineData != null && stock.sparklineData!.isNotEmpty
                  ? LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: const LineTouchData(enabled: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: stock.sparklineData!
                                .asMap()
                                .entries
                                .map(
                                  (e) =>
                                      FlSpot(e.key.toDouble(), e.value.price),
                                )
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
                    )
                  : Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: color,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            // Price and Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(stock.price),
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
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isPositive = stock.isPositive;
    final color = isPositive ? AppTheme.primaryGreen : Colors.red;

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
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            // Symbol and Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    stock.companyName,
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
                  currencyFormat.format(stock.price),
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

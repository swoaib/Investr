import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../domain/stock.dart';
import 'stock_list_controller.dart';
import 'stock_detail_bottom_sheet.dart';
import 'package:investr/l10n/app_localizations.dart';

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
                child: Text(
                  l10n.stockMarketTitle,
                  style: theme.textTheme.headlineLarge,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
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
                  ? _buildSearchResults(controller, l10n)
                  : _buildWatchlist(controller, l10n),
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
      padding: const EdgeInsets.only(
        left: AppTheme.screenPaddingHorizontal,
        right: AppTheme.screenPaddingHorizontal,
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
                    width: 400,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: _StockListItem(stock: stock),
            ),
            if (index < controller.stocks.length - 1) const Divider(height: 1),
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
      padding: const EdgeInsets.only(
        left: AppTheme.screenPaddingHorizontal,
        right: AppTheme.screenPaddingHorizontal,
        bottom: CustomBottomNavigationBar.contentBottomPadding,
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
            // Logo
            _StockLogo(
              url: stock.imageUrl,
              symbol: stock.symbol,
              countryCode: stock.country,
              exchange: stock.exchange,
              currency: stock.currency,
            ),
            const SizedBox(width: 12),
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
            SizedBox(width: 16),
            // Mini Sparkline Chart
            Expanded(
              flex: 1,
              child: SizedBox(
                width: 60,
                height: 30,
                child:
                    stock.sparklineData != null &&
                        stock.sparklineData!.isNotEmpty
                    ? LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: 78, // Fixed full trading day (6.5h / 5min)
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
            ),
            const SizedBox(width: 16),
            // Price and Change
            Expanded(
              flex: 2,
              child: Column(
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
        color: Colors.transparent, // Ensures hit test works on empty space
        child: Row(
          children: [
            // Logo
            _StockLogo(
              url: stock.imageUrl,
              symbol: stock.symbol,
              countryCode: stock.country,
            ),
            const SizedBox(width: 12),
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

class _StockLogo extends StatelessWidget {
  final String url;
  final String symbol;
  final String? countryCode;
  final String? exchange;
  final String? currency;

  const _StockLogo({
    required this.url,
    required this.symbol,
    this.countryCode,
    this.exchange,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        color: isDark ? Colors.grey.shade900 : Colors.white,
        padding: const EdgeInsets.all(6.0),
        child: (symbol.startsWith('^') || symbol.contains('FOREX'))
            ? _buildFallback(isDark)
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallback(isDark),
              ),
      ),
    );
  }

  Widget _buildFallback(bool isDark) {
    // 1. Use API provided country code if available (lowercase)
    // 2. Otherwise infer from exchange/currency/symbol
    final code = countryCode?.toLowerCase() ?? _inferCountryCode();
    final flagUrl = 'https://flagcdn.com/w40/$code.png';

    return Container(
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      alignment: Alignment.center,
      child: Image.network(
        flagUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            symbol.isNotEmpty ? symbol[0] : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          );
        },
      ),
    );
  }

  String _inferCountryCode() {
    // 1. Check Exchange
    if (exchange != null) {
      final ex = exchange!.toUpperCase();
      if (ex.contains('LONDON') || ex == 'LSE' || ex == 'FTSE') return 'gb';
      if (ex.contains('TORONTO') || ex == 'TSX') return 'ca';
      if (ex.contains('PARIS') || ex == 'EURONEXT') {
        return 'fr'; // Catch-all for Euronext often France
      }
      if (ex.contains('FRANKFURT') || ex.contains('XETRA') || ex == 'GER') {
        return 'de';
      }
      if (ex.contains('HONG KONG') || ex == 'HKSE') return 'hk';
      if (ex.contains('INDIA') || ex == 'NSE' || ex == 'BSE') return 'in';
      if (ex.contains('AUSTRALIAN') || ex == 'ASX') return 'au';
      if (ex.contains('SAO PAULO') || ex == 'BOVESPA') return 'br';
      if (ex.contains('TOKYO') || ex == 'JPX') return 'jp';
      if (ex.contains('KOREA') || ex == 'KSE') return 'kr';
      if (ex.contains('SIX')) return 'ch';
    }

    // 2. Check Currency
    if (currency != null) {
      final cur = currency!.toUpperCase();
      switch (cur) {
        case 'GBP':
          return 'gb';
        case 'CAD':
          return 'ca';
        case 'JPY':
          return 'jp';
        case 'AUD':
          return 'au';
        case 'INR':
          return 'in';
        case 'HKD':
          return 'hk';
        case 'BRL':
          return 'br';
        case 'CHF':
          return 'ch';
        case 'CNY':
          return 'cn';
        case 'SGD':
          return 'sg';
        case 'EUR':
          return 'eu'; // Generic EU flag for Euro
      }
    }

    // 3. Handle Suffixes (Exchange) - Fallback
    if (symbol.contains('.')) {
      final suffix = symbol.split('.').last;
      switch (suffix) {
        case 'L':
          return 'gb';
        case 'TO':
          return 'ca';
        case 'PA':
          return 'fr';
        case 'DE':
          return 'de';
        case 'HK':
          return 'hk';
        case 'KS':
          return 'kr';
        case 'SI':
          return 'sg';
        case 'MI':
          return 'it';
        case 'MC':
          return 'es';
        case 'AS':
          return 'nl';
        case 'BR':
          return 'be';
        case 'SW':
          return 'ch'; // Swiss
        case 'SA':
          return 'br'; // Sao Paulo
        case 'V':
          return 'ca'; // TSX Venture
        case 'NE':
          return 'ca'; // NEO
      }
    }

    // 4. Forex/Crypto heuristics
    if (!symbol.contains('.')) {
      if (symbol.startsWith('EUR')) return 'eu';
      if (symbol.startsWith('GBP')) return 'gb';
      if (symbol.startsWith('JPY')) return 'jp';
      if (symbol.startsWith('CAD')) return 'ca';
      if (symbol.startsWith('AUD')) return 'au';
      if (symbol.startsWith('CNY')) return 'cn';
      // Crypto usually has no specific country, but let's default to generic or US.
      // Many crypto tickers like BTCUSD might default to US logic below.
    }

    // 5. Default to US (NYSE/NASDAQ usually have no suffix)
    return 'us';
  }
}

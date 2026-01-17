import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
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

                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (value.isEmpty) {
                      controller.clearSearch();
                    } else {
                      controller.searchStock(value);
                    }
                  });
                },
                onSubmitted: (value) {
                  controller.searchStock(value);
                },
              ),
            ),
            Expanded(
              child: controller.isLoading
                  ? _buildShimmerLoading(context)
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
      padding: const EdgeInsets.only(
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
        padding: const EdgeInsets.only(
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
}

class _StockListItem extends StatelessWidget {
  final Stock stock;

  const _StockListItem({required this.stock});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isPositive = stock.isPositive;
    final color = isPositive ? AppTheme.primaryGreen : Colors.red;

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
            SizedBox(
              width: 60,
              height: 30,
              child:
                  stock.sparklineData != null && stock.sparklineData!.isNotEmpty
                  ? LineChart(
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

                          // Standardize scaling: Min 78 points (US trading day) for "Today"
                          // This ensures "In-Progress" look (Left-to-Right) for all markets.
                          if (isToday) {
                            final count = (points.length - 1).toDouble();
                            return count < 78.0 ? 78.0 : count;
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
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: AppTheme.screenPaddingHorizontal,
        ),
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
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 30,
        height: 30,
        color: (symbol == 'NIO' || symbol == 'AMZN')
            ? Colors.grey.shade900
            : symbol == 'SONY'
            ? Colors.white
            : isDark
            ? Colors.grey.shade900
            : Colors.white,
        padding:
            (symbol == 'AAPL' ||
                symbol.startsWith('^') ||
                symbol.contains('FOREX'))
            ? EdgeInsets.zero
            : const EdgeInsets.all(4.0),
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
    const knownAssets = {
      'ac',
      'ad',
      'ae',
      'af',
      'ag',
      'ai',
      'al',
      'am',
      'ao',
      'aq',
      'ar',
      'as',
      'at',
      'au',
      'aw',
      'ax',
      'az',
      'ba',
      'bb',
      'bd',
      'be',
      'bf',
      'bg',
      'bh',
      'bi',
      'bj',
      'bl',
      'bm',
      'bn',
      'bo',
      'bq',
      'br',
      'bs',
      'bt',
      'bv',
      'bw',
      'by',
      'bz',
      'ca',
      'cc',
      'cd',
      'cf',
      'cg',
      'ch',
      'ci',
      'ck',
      'cl',
      'cm',
      'cn',
      'co',
      'cp',
      'cr',
      'cu',
      'cv',
      'cw',
      'cx',
      'cy',
      'cz',
      'de',
      'dg',
      'dj',
      'dk',
      'dm',
      'do',
      'dz',
      'ea',
      'ec',
      'ee',
      'eg',
      'eh',
      'er',
      'es-ct',
      'es-ga',
      'es',
      'et',
      'eu',
      'fi',
      'fj',
      'fk',
      'fm',
      'fo',
      'fr',
      'ga',
      'gb-eng',
      'gb-nir',
      'gb-sct',
      'gb-wls',
      'gb',
      'gd',
      'ge',
      'gf',
      'gg',
      'gh',
      'gi',
      'gl',
      'gm',
      'gn',
      'gp',
      'gq',
      'gr',
      'gs',
      'gt',
      'gu',
      'gw',
      'gy',
      'hk',
      'hm',
      'hn',
      'hr',
      'ht',
      'hu',
      'ic',
      'id',
      'ie',
      'il',
      'im',
      'in',
      'io',
      'iq',
      'ir',
      'is',
      'it',
      'je',
      'jm',
      'jo',
      'jp',
      'ke',
      'kg',
      'kh',
      'ki',
      'km',
      'kn',
      'kp',
      'kr',
      'kw',
      'ky',
      'kz',
      'la',
      'lb',
      'lc',
      'li',
      'lk',
      'lr',
      'ls',
      'lt',
      'lu',
      'lv',
      'ly',
      'ma',
      'mc',
      'md',
      'me',
      'mf',
      'mg',
      'mh',
      'mk',
      'ml',
      'mm',
      'mn',
      'mo',
      'mp',
      'mq',
      'mr',
      'ms',
      'mt',
      'mu',
      'mv',
      'mw',
      'mx',
      'my',
      'mz',
      'na',
      'nc',
      'ne',
      'nf',
      'ng',
      'ni',
      'nl',
      'no',
      'np',
      'nr',
      'nu',
      'nz',
      'om',
      'pa',
      'pe',
      'pf',
      'pg',
      'ph',
      'pk',
      'pl',
      'pm',
      'pn',
      'pr',
      'ps',
      'pt',
      'pw',
      'py',
      'qa',
      're',
      'ro',
      'rs',
      'ru',
      'rw',
      'sa',
      'sb',
      'sc',
      'sd',
      'se',
      'sg',
      'sh',
      'si',
      'sj',
      'sk',
      'sl',
      'sm',
      'sn',
      'so',
      'sr',
      'ss',
      'st',
      'sv',
      'sx',
      'sy',
      'sz',
      'ta',
      'tc',
      'td',
      'tf',
      'tg',
      'th',
      'tj',
      'tk',
      'tl',
      'tm',
      'tn',
      'to',
      'tr',
      'tt',
      'tv',
      'tw',
      'tz',
      'ua',
      'ug',
      'um',
      'un',
      'us',
      'uy',
      'uz',
      'va',
      'vc',
      've',
      'vg',
      'vi',
      'vn',
      'vu',
      'wf',
      'ws',
      'xk',
      'xx',
      'ye',
      'yt',
      'za',
      'zm',
      'zw',
    };
    final useLocal = knownAssets.contains(code);

    return Container(
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      alignment: Alignment.center,
      child: useLocal
          ? SvgPicture.asset(
              'assets/flags/$code.svg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.network(
              'https://flagcdn.com/w80/$code.png',
              width: double.infinity,
              height: double.infinity,
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
    // 0. Explicit Index Overrides
    if (symbol == '^N225') return 'jp'; // Nikkei 225
    if (symbol == '^HSI') return 'hk'; // Hang Seng
    if (symbol == '^FTSE') return 'gb'; // FTSE 100
    if (symbol == '^GDAXI') return 'de'; // DAX
    if (symbol == '^FCHI') return 'fr'; // CAC 40
    if (symbol == '^KS11') return 'kr'; // KOSPI
    if (symbol == '^BSESN') return 'in'; // BSE Sensex
    if (symbol == '^STI') return 'sg'; // Straits Times

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

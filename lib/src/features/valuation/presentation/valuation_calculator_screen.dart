import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../market_data/data/stock_repository.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:investr/l10n/app_localizations.dart';
import 'dart:async';

class ValuationCalculatorScreen extends StatefulWidget {
  const ValuationCalculatorScreen({super.key});

  @override
  State<ValuationCalculatorScreen> createState() =>
      _ValuationCalculatorScreenState();
}

class _ValuationCalculatorScreenState extends State<ValuationCalculatorScreen> {
  final _stockRepository = StockRepository();
  final TextEditingController _symbolController = TextEditingController();

  bool _isLoading = false;
  double? _fmpDcfValue;
  double? _currentPrice;

  // Search State
  Timer? _searchDebounce;
  List<({String symbol, String name})> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _symbolController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isSearching = true);

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _stockRepository.searchTicker(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  // Method to select a stock from search results
  void _selectStock(String symbol) {
    _symbolController.text = symbol;
    if (mounted) {
      setState(() {
        _searchResults = []; // Clear results to hide list
        _isSearching = false;
      });
    }
    _fetchStockData();
    FocusScope.of(context).unfocus(); // Close keyboard
  }

  Future<void> _fetchStockData() async {
    final symbol = _symbolController.text.trim().toUpperCase();
    if (symbol.isEmpty) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      // 1. Fetch FMP DCF Value
      final dcfValue = await _stockRepository.getFMPDCFValue(symbol);

      // 2. Fetch Current Price
      final stock = await _stockRepository.getStock(symbol);
      final price = stock?.price;

      if (mounted) {
        setState(() {
          _fmpDcfValue = dcfValue;
          _currentPrice = price;
        });

        if (dcfValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not fetch valuation data for $symbol'),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showInfoDialog() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.howItWorks,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'This screen displays the Intrinsic Value calculated by the Discounted Cash Flow (DCF) model provided by Financial Modeling Prep (FMP). It compares this value to the current market price to estimate if the stock is undervalued or overvalued.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontSize: 16,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).cardTheme.color,
                    foregroundColor: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color,
                    elevation: 0,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(l10n.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.screenPaddingHorizontal,
              AppTheme.screenPaddingVertical,
              AppTheme.screenPaddingHorizontal,
              CustomBottomNavigationBar.contentBottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.valuationDisplayTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    IconButton(
                      onPressed: _showInfoDialog,
                      icon: const Icon(Icons.info_outline_rounded),
                      color: AppTheme.textGrey,
                      tooltip: l10n.howItWorks,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'FMP DCF Model',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGrey),
                ),
                const SizedBox(height: 24),

                // Stock Search Field
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _symbolController,
                        onChanged: _onSearchChanged, // Hook up live search
                        decoration: InputDecoration(
                          labelText: l10n.selectStock,
                          hintText: l10n.searchHint,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppTheme.primaryGreen,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                  ),
                                  onPressed:
                                      _fetchStockData, // Keep manual trigger as well
                                ),
                        ),
                      ),

                      // Inline Search Results
                      if (_isSearching)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: LinearProgressIndicator(minHeight: 2),
                        ),

                      if (_searchResults.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                            ),
                            itemBuilder: (context, index) {
                              final stock = _searchResults[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  stock.symbol,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  stock.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _selectStock(stock.symbol),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                if (_fmpDcfValue != null)
                  _buildResultCard(context, l10n)
                else if (!_isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: AppTheme.textGrey.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.trackYourStocksDesc,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.textGrey),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, AppLocalizations l10n) {
    final currency = NumberFormat.simpleCurrency();
    final intrinsicValue = _fmpDcfValue!;
    final currentPrice = _currentPrice ?? 0;
    final isUndervalued = intrinsicValue > currentPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).cardTheme.color!.withValues(alpha: 0.9),
            Theme.of(context).cardTheme.color!.withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUndervalued ? AppTheme.primaryGreen : Colors.redAccent)
                .withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.intrinsicValue,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currency.format(intrinsicValue),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: isUndervalued ? AppTheme.primaryGreen : Colors.redAccent,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.currentPrice}: ',
                  style: const TextStyle(color: AppTheme.textGrey),
                ),
                Text(
                  currency.format(currentPrice),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

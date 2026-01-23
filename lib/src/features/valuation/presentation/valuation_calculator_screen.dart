import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/currency/currency_controller.dart';
import '../../market_data/data/stock_repository.dart';
import '../../market_data/domain/stock.dart';
import '../../valuation/domain/advanced_dcf_data.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../../../shared/widgets/stock_logo.dart';
import 'package:investr/l10n/app_localizations.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/services/analytics_service.dart';

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
  AdvancedDCFData? _dcfData;
  double? _currentPrice;

  // Custom Overrides
  double? _customWacc;
  double? _customTaxRate;
  double? _customGrowthRate;
  double? _customRiskFreeRate;
  double? _customBeta;

  // Search State
  Timer? _searchDebounce;
  List<Stock> _searchResults = [];
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
        // 1. Search for tickers
        final tickerResults = await _stockRepository.searchTicker(query);

        if (tickerResults.isEmpty) {
          if (mounted) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
          }
          return;
        }

        // 2. Fetch details (enrichment) for logos, etc.
        // Limit to top 5 to avoid heavy API usage if needed, though searchTicker limits to 10.
        final stocks = await Future.wait(
          tickerResults.map(
            (t) => _stockRepository.getStock(t.symbol, name: t.name),
          ),
        );

        final validStocks = stocks.whereType<Stock>().toList();

        if (mounted) {
          setState(() {
            _searchResults = validStocks;
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
      // 1. Fetch Advanced DCF Value
      final dcfData = await _stockRepository.getAdvancedDCF(
        symbol,
        wacc: _customWacc,
        taxRate: _customTaxRate,
        longTermGrowthRate: _customGrowthRate,
        riskFreeRate: _customRiskFreeRate,
        beta: _customBeta,
      );

      if (dcfData != null && mounted) {
        context.read<AnalyticsService>().logCalculatorUsage(
          symbol: symbol,
          result: dcfData.dcf,
          wacc: dcfData.wacc,
          growthRate: dcfData.longTermGrowthRate,
        );
      }

      // 2. Fetch Current Price
      final stock = await _stockRepository.getStock(symbol);
      final price = stock?.price;

      if (mounted) {
        setState(() {
          _dcfData = dcfData;
          _currentPrice = price;
        });

        if (dcfData == null) {
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

  void _resetAssumptions() {
    setState(() {
      _customWacc = null;
      _customGrowthRate = null;
      _customTaxRate = null;
      _customRiskFreeRate = null;
      _customBeta = null;
    });
    _fetchStockData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyController = context.watch<CurrencyController>();

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FMP DCF Model',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGrey,
                      ),
                    ),
                    if (currencyController.currency != 'USD')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).chipTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '1 USD = ${currencyController.exchangeRate.toStringAsFixed(2)} ${currencyController.currency}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stock Search Field
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isLoading
                          ? AppTheme.primaryGreen
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      if (_isLoading)
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 0,
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
                          contentPadding: const EdgeInsets.all(14),
                          suffixIcon: _isLoading
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5,
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
                                leading: StockLogo(
                                  url: stock.imageUrl,
                                  symbol: stock.symbol,
                                  countryCode: stock.country,
                                  exchange: stock.exchange,
                                  currency: stock.currency,
                                ),
                                title: Text(
                                  stock.symbol,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  stock.companyName,
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

                if (_dcfData != null) ...[
                  _buildResultCard(context, l10n),
                  const SizedBox(height: 24),
                  _buildBreakdownCard(context, l10n),
                  const SizedBox(height: 24),
                  _buildProjectionsCard(context),
                  const SizedBox(height: 24),
                  _buildEnterpriseEquityCard(context, l10n),
                ] else if (!_isLoading)
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
    final currencyController = context.watch<CurrencyController>();
    final rate = currencyController.exchangeRate;

    // Use controller's symbol (handles 'NOK' override) and add space
    final currencySymbol = currencyController.currencySymbol;
    final isIndex = _symbolController.text.trim().startsWith('^');
    final currencyFormat = isIndex
        ? NumberFormat.currency(symbol: '')
        : currencySymbol == 'kr'
        ? NumberFormat.currency(symbol: '$currencySymbol ')
        : NumberFormat.currency(symbol: currencySymbol);

    final intrinsicValue = _dcfData!.dcf * rate;
    final currentPrice = (_currentPrice ?? 0) * rate;
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
          if (intrinsicValue < 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dcfData!.longTermGrowthRate >= _dcfData!.wacc
                          ? 'Long-Term Growth Rate (${_dcfData!.longTermGrowthRate.toStringAsFixed(2)}%) is higher than WACC (${_dcfData!.wacc.toStringAsFixed(2)}%). This invalidates the terminal value calculation.'
                          : 'The intrinsic value is negative, likely due to negative projected Free Cash Flows or high debt.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            currencyFormat.format(intrinsicValue),
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
                  currencyFormat.format(currentPrice),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomizationSheet() {
    if (_dcfData == null) return;

    final waccController = TextEditingController(
      text: (_dcfData!.wacc).toStringAsFixed(2),
    );
    final growthController = TextEditingController(
      text: (_dcfData!.longTermGrowthRate).toStringAsFixed(2),
    );
    final taxController = TextEditingController(
      text: (_dcfData!.taxRate).toStringAsFixed(2),
    );
    final riskFreeController = TextEditingController(
      text: (_dcfData!.riskFreeRate).toStringAsFixed(2),
    );
    final betaController = TextEditingController(
      text: (_dcfData!.beta).toStringAsFixed(2),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customize Assumptions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildInputRow(context, 'WACC (%)', waccController),
              const SizedBox(height: 16),
              _buildInputRow(context, 'Long-Term Growth (%)', growthController),
              const SizedBox(height: 16),
              _buildInputRow(context, 'Tax Rate (%)', taxController),
              const SizedBox(height: 16),
              _buildInputRow(context, 'Risk Free Rate (%)', riskFreeController),
              const SizedBox(height: 16),
              _buildInputRow(context, 'Beta', betaController),
              const SizedBox(height: 32),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _customWacc = double.tryParse(waccController.text);
                      _customGrowthRate = double.tryParse(
                        growthController.text,
                      );
                      _customTaxRate = double.tryParse(taxController.text);
                      _customRiskFreeRate = double.tryParse(
                        riskFreeController.text,
                      );
                      _customBeta = double.tryParse(betaController.text);
                    });
                    Navigator.pop(context);
                    _fetchStockData();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Calculate'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGrey),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardTheme.color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    String value, {
    bool isHeader = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isHeader
                ? Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGrey),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isHeader
                  ? null
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(BuildContext context, AppLocalizations l10n) {
    final percent = NumberFormat.percentPattern();

    final hasCustomizations =
        _customWacc != null ||
        _customGrowthRate != null ||
        _customTaxRate != null ||
        _customRiskFreeRate != null ||
        _customBeta != null;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Key Assumptions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasCustomizations)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Custom',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBreakdownRow(
                context,
                'WACC',
                percent.format(_dcfData!.wacc / 100),
              ),
              const Divider(),
              _buildBreakdownRow(
                context,
                'Tax Rate',
                percent.format(_dcfData!.taxRate),
              ),
              const Divider(),
              _buildBreakdownRow(
                context,
                'Long-Term Growth Rate',
                percent.format(_dcfData!.longTermGrowthRate / 100),
              ),
              const Divider(),
              _buildBreakdownRow(
                context,
                'Risk Free Rate',
                percent.format(_dcfData!.riskFreeRate / 100),
              ),
              const Divider(),
              _buildBreakdownRow(
                context,
                'Beta',
                _dcfData!.beta.toStringAsFixed(2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showCustomizationSheet,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Customize Assumptions'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (hasCustomizations) ...[
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: _resetAssumptions,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildEnterpriseEquityCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final currencyController = context.watch<CurrencyController>();
    final rate = currencyController.exchangeRate;
    final currencySymbol = currencyController.currencySymbol;
    final currencyFormat = NumberFormat.compactCurrency(
      symbol: _symbolController.text.trim().startsWith('^')
          ? ''
          : '$currencySymbol ',
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valuation Bridge',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildBreakdownRow(
            context,
            'Sum of PV Free Cash Flows',
            currencyFormat.format(_dcfData!.sumPvUfcf * rate),
          ),
          _buildBreakdownRow(
            context,
            '+ PV of Terminal Value',
            currencyFormat.format(_dcfData!.presentTerminalValue * rate),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 2),
          ),
          _buildBreakdownRow(
            context,
            '= Enterprise Value',
            currencyFormat.format(_dcfData!.enterpriseValue * rate),
            isHeader: true,
          ),
          const SizedBox(height: 8),
          _buildBreakdownRow(
            context,
            '- Net Debt (Total Debt - Cash)',
            currencyFormat.format(_dcfData!.netDebt * rate),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 2),
          ),
          _buildBreakdownRow(
            context,
            '= Equity Value',
            currencyFormat.format(_dcfData!.equityValue * rate),
            isHeader: true,
          ),
          const SizedBox(height: 8),
          _buildBreakdownRow(
            context,
            '/ Shares Outstanding',
            NumberFormat.compact().format(_dcfData!.dilutedSharesOutstanding),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 2),
          ),
          _buildBreakdownRow(
            context,
            '= Fair Value per Share',
            currencyFormat.format(_dcfData!.dcf * rate),
            isHeader: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionsCard(BuildContext context) {
    if (_dcfData == null || _dcfData!.yearlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final currencyController = context.watch<CurrencyController>();
    final rate = currencyController.exchangeRate;
    final currencySymbol = currencyController.currencySymbol;
    final currencyFormat = NumberFormat.compactCurrency(
      symbol: _symbolController.text.trim().startsWith('^')
          ? ''
          : '$currencySymbol ',
    );

    final data = List<YearlyDCFData>.from(_dcfData!.yearlyData)
      ..sort((a, b) => a.year.compareTo(b.year));

    // Take last 5 years if too many
    final displayData = data.length > 5 ? data.sublist(data.length - 5) : data;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Future Cash Flow Projections',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlevered Free Cash Flow (UFCF)',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textGrey),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    displayData
                        .map((e) => e.ufcf * rate)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Theme.of(context).cardTheme.color!,
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final year = displayData[group.x.toInt()].year;
                      final value = currencyFormat.format(rod.toY);
                      return BarTooltipItem(
                        '$year\n',
                        const TextStyle(
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: value,
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= displayData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            displayData[value.toInt()].year.toString(),
                            style: const TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: displayData.asMap().entries.map((entry) {
                  final convertedUfcf = entry.value.ufcf * rate;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: convertedUfcf,
                        color: AppTheme.primaryGreen,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY:
                              displayData
                                  .map((e) => e.ufcf * rate)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.1,
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

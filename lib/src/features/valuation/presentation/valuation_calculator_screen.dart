import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../market_data/data/stock_repository.dart';
import '../domain/dcf_data.dart';
import '../domain/dcf_result.dart'; // Import DCFResult
import '../domain/valuation_logic.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:investr/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:math';

class ValuationCalculatorScreen extends StatefulWidget {
  const ValuationCalculatorScreen({super.key});

  @override
  State<ValuationCalculatorScreen> createState() =>
      _ValuationCalculatorScreenState();
}

class _ValuationCalculatorScreenState extends State<ValuationCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stockRepository = StockRepository();

  // Controllers
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _growthController = TextEditingController();
  final TextEditingController _terminalGrowthController =
      TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  bool _isLoading = false;
  DCFResult? _result; // Update type
  bool _showDetailedReport = false; // Toggle state
  DCFData? _currentData;

  // Search State
  Timer? _searchDebounce;
  List<({String symbol, String name})> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Set defaults
    _growthController.text = '10';
    _terminalGrowthController.text = '3';
    _discountController.text = '9';
    _yearsController.text = '10';
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _growthController.dispose();
    _terminalGrowthController.dispose();
    _discountController.dispose();
    _yearsController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

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
    setState(() {
      _searchResults = []; // Clear results to hide list
      _isSearching = false;
    });
    _fetchStockData();
    FocusScope.of(context).unfocus(); // Close keyboard
  }

  Future<void> _fetchStockData() async {
    final symbol = _symbolController.text.trim().toUpperCase();
    if (symbol.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final data = await _stockRepository.getDCFData(symbol);
      if (data != null) {
        setState(() {
          _currentData = data;
          _result = null; // Reset result until calculated
        });

        // Auto-calculate if data looks good
        if (data.freeCashFlow != 0 && data.sharesOutstanding > 0) {
          _calculate();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch financial data')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculate() {
    if (_formKey.currentState!.validate() && _currentData != null) {
      final growth = double.tryParse(_growthController.text) ?? 0;
      final termGrowth = double.tryParse(_terminalGrowthController.text) ?? 0;
      final discount = double.tryParse(_discountController.text) ?? 0;
      final years = int.tryParse(_yearsController.text) ?? 10;

      setState(() {
        _result = ValuationLogic.calculateRealDCF(
          freeCashFlow: _currentData!.freeCashFlow,
          growthRate: growth,
          terminalGrowthRate: termGrowth,
          discountRate: discount,
          years: years,
          netDebt: _currentData!.netDebt,
          sharesOutstanding: _currentData!.sharesOutstanding,
        );
      });
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
                l10n.dcfExplanation,
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
            child: Form(
              key: _formKey,
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
                    l10n.calcIntrinsicValueDesc,
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

                  // Assumptions Card
                  if (_currentData != null) ...[
                    Text(
                      l10n.assumptions,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactInput(
                                  controller: _growthController,
                                  label: l10n.growthRate,
                                  suffix: '%',
                                  //l10n: l10n,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCompactInput(
                                  controller: _terminalGrowthController,
                                  label: l10n.terminalRate,
                                  suffix: '%',
                                  //l10n: l10n,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactInput(
                                  controller: _discountController,
                                  label: l10n.discountRate,
                                  suffix: '%',
                                  //l10n: l10n,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCompactInput(
                                  controller: _yearsController,
                                  label: l10n.years,
                                  suffix: '',
                                  //l10n: l10n,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.calculate,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Empty State
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
                              l10n.trackYourStocksDesc, // Use descriptive placeholder
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppTheme.textGrey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Result Card
                  if (_result != null && _currentData != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(
                              context,
                            ).cardTheme.color!.withValues(alpha: 0.9),
                            Theme.of(
                              context,
                            ).cardTheme.color!.withValues(alpha: 0.5),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_result!.intrinsicValue > _currentData!.price
                                        ? AppTheme.primaryGreen
                                        : Colors.redAccent)
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTheme.textGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            NumberFormat.simpleCurrency().format(
                              _result?.intrinsicValue,
                            ),
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color:
                                      (_result?.intrinsicValue ?? 0) >
                                          _currentData!.price
                                      ? AppTheme.primaryGreen
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${l10n.currentPrice}: ',
                                  style: TextStyle(color: AppTheme.textGrey),
                                ),
                                Text(
                                  NumberFormat.simpleCurrency().format(
                                    _currentData!.price,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_result != null) ...[
                    const SizedBox(height: 24),
                    SwitchListTile.adaptive(
                      value: _showDetailedReport,
                      onChanged: (val) =>
                          setState(() => _showDetailedReport = val),
                      title: const Text(
                        'Show Detailed Report',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      activeTrackColor: AppTheme.primaryGreen,
                    ),
                    if (_showDetailedReport) _buildDetailedReport(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInput({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textGrey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            hintText: '0',
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDetailedReport() {
    final currency = NumberFormat.compactSimpleCurrency();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 24),

        // 1. Fetched Data Table
        Text(
          '1. Fetched Financial Data',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              _buildDataRow(
                'Market Price',
                currency.format(_currentData!.price),
              ),
              const Divider(height: 24),
              _buildDataRow(
                'Free Cash Flow (FCF)',
                currency.format(_currentData!.freeCashFlow),
              ),
              const Divider(height: 24),
              _buildDataRow(
                'Shares Outstanding',
                NumberFormat.compact().format(_currentData!.sharesOutstanding),
              ),
              const Divider(height: 24),
              _buildDataRow('Net Debt', currency.format(_currentData!.netDebt)),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // 2. Projected Future FCFs (Graph)
        Text(
          '2. Projected Future Cash Flows',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.5,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 24, 24, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _result!.futureCashFlows.values.reduce(max) * 1.1,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Theme.of(context).cardColor,

                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        NumberFormat.compactSimpleCurrency().format(rod.toY),
                        TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            NumberFormat.compact().format(value),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Y${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _result!.futureCashFlows.entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: AppTheme.primaryGreen.withValues(alpha: 0.7),
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // 3. Formula Explanation
        Text(
          '3. Calculation Breakdown',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Intrinsic Value per Share =',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                '(Sum of Discounted FCFs + Discounted Terminal Value - Net Debt) / Shares Outstanding',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildDataRow(
                'Sum of Discounted FCFs',
                currency.format(
                  _result!.enterpriseValue - _result!.presentTerminalValue,
                ),
              ),
              const SizedBox(height: 8),
              _buildDataRow(
                '+ Present Terminal Value',
                currency.format(_result!.presentTerminalValue),
              ),
              const SizedBox(height: 8),
              const Divider(),
              _buildDataRow(
                '= Total Enterprise Value',
                currency.format(_result!.enterpriseValue),
                isBold: true,
              ),
              const SizedBox(height: 8),
              _buildDataRow(
                '- Net Debt',
                currency.format(_result!.netDebt),
                color: Colors.redAccent,
              ),
              const SizedBox(height: 8),
              const Divider(),
              _buildDataRow(
                '= Equity Value',
                currency.format(_result!.equityValue),
                isBold: true,
              ),
              const SizedBox(height: 8),
              _buildDataRow(
                '/ Shares Outstanding',
                NumberFormat.compact().format(_currentData!.sharesOutstanding),
              ),
              const SizedBox(height: 8),
              const Divider(),
              _buildDataRow(
                '= Intrinsic Value',
                currency.format(_result!.intrinsicValue),
                isBold: true,
                color: AppTheme.primaryGreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDataRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppTheme.textGrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

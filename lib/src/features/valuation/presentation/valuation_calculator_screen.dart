import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../market_data/data/stock_repository.dart';
import '../domain/dcf_data.dart';
import '../domain/valuation_logic.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:investr/l10n/app_localizations.dart';

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
  double? _result;
  DCFData? _currentData;

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
    super.dispose();
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

  void _showStockSearch() {
    showSearch(
      context: context,
      delegate: _StockSearchDelegate(_stockRepository),
    ).then((selectedSymbol) {
      if (selectedSymbol != null) {
        _symbolController.text = selectedSymbol;
        _fetchStockData();
      }
    });
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
                  Text(
                    l10n.valuationDisplayTitle,
                    style: Theme.of(context).textTheme.headlineLarge,
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
                    child: TextFormField(
                      controller: _symbolController,
                      decoration: InputDecoration(
                        labelText: l10n.selectStock,
                        hintText: l10n.searchHint, // "e.g. AAPL"
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
                                onPressed: _showStockSearch,
                              ),
                      ),
                      readOnly: true,
                      onTap: _showStockSearch,
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
                                (_result! > _currentData!.price
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
                            NumberFormat.simpleCurrency().format(_result),
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: _result! > _currentData!.price
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
}

class _StockSearchDelegate extends SearchDelegate<String?> {
  final StockRepository repository;

  _StockSearchDelegate(this.repository);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<({String symbol, String name})>>(
      future: repository.searchTicker(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found for "$query"'));
        }

        final results = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final stock = results[index];
            return ListTile(
              title: Text(stock.symbol),
              subtitle: Text(stock.name),
              onTap: () {
                close(context, stock.symbol);
              },
            );
          },
        );
      },
    );
  }
}

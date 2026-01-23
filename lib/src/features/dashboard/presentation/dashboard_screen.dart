import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../shared/services/analytics_service.dart';
import '../../market_data/presentation/stock_list_controller.dart';
import '../../education/presentation/learn_screen.dart';
import '../../valuation/presentation/valuation_calculator_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../../../shared/theme/app_theme.dart';

import '../../market_data/presentation/stock_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    final controller = context.read<StockListController>();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isEmpty) {
        controller.clearSearch();
      } else {
        context.read<AnalyticsService>().logSearch(value);
        controller.searchStock(value);
      }
    });
  }

  // Placeholder pages for now
  final List<Widget> _pages = [
    const StockListScreen(),
    const LearnScreen(),
    const ValuationCalculatorScreen(),
    const SettingsScreen(), // Real Settings
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _pages),
          if (_isSearchActive)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8.0,
                  ),
                  child: _buildSearchBar(context),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isSearchActive
          ? const SizedBox.shrink()
          : CustomBottomNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              onSearchTap: () {
                setState(() {
                  _isSearchActive = true;
                  _selectedIndex = 0; // Switch to Stock List to see results
                });
                // Request focus after the frame build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _searchFocusNode.requestFocus();
                });
              },
              items: [
                CustomNavItem(
                  icon: Icons.show_chart_outlined,
                  label: l10n.navStocks,
                  activeIcon: Icons.show_chart,
                ),
                CustomNavItem(
                  icon: Icons.school_outlined,
                  label: l10n.navLearn,
                  activeIcon: Icons.school,
                ),
                CustomNavItem(
                  icon: Icons.calculate_outlined,
                  label: l10n.navValue,
                  activeIcon: Icons.calculate,
                ),
                CustomNavItem(
                  icon: Icons.settings_outlined,
                  label: l10n.navSettings,
                  activeIcon: Icons.settings,
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.search, color: Colors.grey),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: const TextStyle(fontSize: 16),
                          cursorColor: AppTheme.textGrey,
                          decoration: InputDecoration(
                            hintText: l10n.searchHint,
                            filled: false,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.only(bottom: 4),
                          ),
                          textInputAction: TextInputAction.search,
                          onChanged: _handleSearch,
                          onSubmitted: _handleSearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearchActive = false;
            });
            _searchController.clear();
            context.read<StockListController>().clearSearch();
            _searchFocusNode.unfocus();
          },
          child: Container(
            height: 45.0,
            width: 45.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Icon(Icons.close, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

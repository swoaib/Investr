import 'package:flutter/material.dart';
import '../../market_data/presentation/stock_list_screen.dart';
import '../../education/presentation/learn_screen.dart';
import '../../valuation/presentation/valuation_calculator_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

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
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.show_chart, l10n.navStocks),
              _buildNavItem(
                1,
                Icons.school_outlined,
                l10n.navLearn,
                activeIcon: Icons.school,
              ),
              _buildNavItem(
                2,
                Icons.calculate_outlined,
                l10n.navValue,
                activeIcon: Icons.calculate,
              ),
              _buildNavItem(
                3,
                Icons.settings_outlined,
                l10n.navSettings,
                activeIcon: Icons.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    IconData? activeIcon,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppTheme.primaryGreen : Colors.blueGrey;

    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(
        isSelected ? (activeIcon ?? icon) : icon,
        color: color,
        size: 24,
      ),
      tooltip: label,
    );
  }
}

import 'package:flutter/material.dart';
import '../../education/presentation/learn_screen.dart';
import '../../valuation/presentation/valuation_calculator_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Placeholder pages for now
  final List<Widget> _pages = [
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
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        items: [
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
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<CustomNavItem> items;

  // Layout Constants
  static const double height = 60.0;
  static const double bottomPadding = 24.0;
  static const double totalHeight = height + bottomPadding;
  // Standard content padding to ensure items above navbar are clickable
  static const double contentBottomPadding = totalHeight + 16.0;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
      child: Container(
        height: height,
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
          children: items.map((item) {
            final index = items.indexOf(item);
            return _buildNavItem(index, item);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, CustomNavItem item) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? AppTheme.primaryGreen : Colors.grey;

    return IconButton(
      onPressed: () => onItemTapped(index),
      icon: Icon(
        isSelected ? (item.activeIcon ?? item.icon) : item.icon,
        color: color,
        size: 24,
      ),
      tooltip: item.label,
    );
  }
}

class CustomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  CustomNavItem({required this.icon, required this.label, this.activeIcon});
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/theme_controller.dart';
import '../../../shared/settings/settings_controller.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final settingsController = context.watch<SettingsController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.themeMode, // We'll rename this key to "Appearance" in arb later, or use existing for now
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock Ticker Toggle
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock Ticker', // TODO: Add to L10n
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Show market data at top of dashboard', // TODO: Add to L10n
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: settingsController.showStockTicker,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (value) {
                      settingsController.toggleStockTicker(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Theme Selection (Reusing style from Onboarding)
            Text(
              l10n.themeMode,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ThemePreviewCard(
                        mode: ThemeMode.light,
                        label: l10n.light,
                        isSelected:
                            themeController.themeMode == ThemeMode.light,
                        onTap: () =>
                            themeController.updateThemeMode(ThemeMode.light),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemePreviewCard(
                        mode: ThemeMode.dark,
                        label: l10n.dark,
                        isSelected: themeController.themeMode == ThemeMode.dark,
                        onTap: () =>
                            themeController.updateThemeMode(ThemeMode.dark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ThemePreviewCard(
                  mode: ThemeMode.system,
                  label: l10n.system,
                  isSelected: themeController.themeMode == ThemeMode.system,
                  onTap: () =>
                      themeController.updateThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final ThemeMode mode;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.mode,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                width: 3,
              ),
            ),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildPreview(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryGreen : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    switch (mode) {
      case ThemeMode.light:
        return _buildThemeMockup(
          backgroundColor: AppTheme.backgroundLight,
          cardColor: AppTheme.cardColorLight,
          textColor: AppTheme.textDark,
        );
      case ThemeMode.dark:
        return _buildThemeMockup(
          backgroundColor: AppTheme.backgroundDark,
          cardColor: AppTheme.cardColorDark,
          textColor: AppTheme.textLight,
        );
      case ThemeMode.system:
        return Row(
          children: [
            Expanded(
              child: _buildThemeMockup(
                backgroundColor: AppTheme.backgroundLight,
                cardColor: AppTheme.cardColorLight,
                textColor: AppTheme.textDark,
                showTitle: false,
              ),
            ),
            Expanded(
              child: _buildThemeMockup(
                backgroundColor: AppTheme.backgroundDark,
                cardColor: AppTheme.cardColorDark,
                textColor: AppTheme.textLight,
                showTitle: false,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildThemeMockup({
    required Color backgroundColor,
    required Color cardColor,
    required Color textColor,
    bool showTitle = true,
  }) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.show_chart,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

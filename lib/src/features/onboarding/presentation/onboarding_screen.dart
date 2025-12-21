import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:investr/l10n/app_localizations.dart';
import 'package:investr/src/shared/locale/locale_controller.dart';
import 'package:investr/src/shared/theme/theme_controller.dart';
import 'onboarding_controller.dart';
import '../../../shared/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();
    final l10n = AppLocalizations.of(context)!;

    // Define pages here to access l10n
    final pages = [
      OnboardingPage(
        title: l10n.trackYourStocks,
        description: l10n.trackYourStocksDesc,
        imagePath: 'assets/images/onboarding/track_stocks.svg',
      ),
      OnboardingPage(
        title: l10n.learnToInvest,
        description: l10n.learnToInvestDesc,
        imagePath: 'assets/images/onboarding/learn_invest.svg',
      ),
      OnboardingPage(
        title: l10n.valueYourPortfolio,
        description: l10n.valueYourPortfolioDesc,
        imagePath: 'assets/images/onboarding/value_portfolio.svg',
      ),
      _ThemeSelectionPage(
        title: l10n.chooseTheme,
        description: l10n.chooseThemeDesc,
        imagePath: 'assets/images/onboarding/theme_selection.svg',
      ),
      _LanguageSelectionPage(
        title: l10n.chooseLanguage,
        description: l10n.chooseLanguageDesc,
        imagePath: 'assets/images/onboarding/language_selection.svg',
      ),
    ];

    // Update total pages in controller if needed, or just use list length
    // Ideally controller should know about page count.
    // For simplicity, we assume controller logic handles next/done based on index.

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  controller.completeOnboarding(context);
                  context.go('/');
                },
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: controller.currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: controller.currentPage == index
                              ? AppTheme.primaryGreen
                              : Theme.of(
                                  context,
                                ).disabledColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Next/Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      if (controller.currentPage == pages.length - 1) {
                        controller.completeOnboarding(context);
                        context.go('/');
                      } else {
                        controller.nextPage();
                      }
                    },
                    child: Text(
                      controller.currentPage == pages.length - 1
                          ? l10n
                                .next // "Get Started" or "Done" - using "Next" or "Done" from l10n? reusing "Next" logic or custom
                          : l10n.next,
                    ),
                    // Note: Ideally "Get Started" for last page. using l10n.done for now if available or hardcoded if strictly needed,
                    // but "Next" works. Let's check if we have "Get Started" or "Done". We have "Done" in ARB.
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

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(imagePath, height: 250),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LanguageSelectionPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const _LanguageSelectionPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final localeController = context.watch<LocaleController>();
    return Padding(
      padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(imagePath, height: 180),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Language Options
          RadioGroup<Locale?>(
            groupValue: localeController.locale,
            onChanged: (val) {
              if (val != null) localeController.updateLocale(val);
            },
            child: Column(
              children: [
                _buildLanguageOption(context, 'English', const Locale('en')),
                _buildLanguageOption(context, 'Norsk', const Locale('no')),
                _buildLanguageOption(context, '日本語', const Locale('ja')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    Locale locale,
  ) {
    return RadioListTile<Locale>(
      value: locale,
      title: Text(label),
      activeColor: AppTheme.primaryGreen,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ThemeSelectionPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const _ThemeSelectionPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Theme Preview Grid
          Row(
            children: [
              Expanded(
                child: _ThemePreviewCard(
                  mode: ThemeMode.light,
                  label: l10n.light,
                  isSelected: themeController.themeMode == ThemeMode.light,
                  onTap: () => themeController.updateThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ThemePreviewCard(
                  mode: ThemeMode.dark,
                  label: l10n.dark,
                  isSelected: themeController.themeMode == ThemeMode.dark,
                  onTap: () => themeController.updateThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ThemePreviewCard(
            mode: ThemeMode.system,
            label: l10n.system,
            isSelected: themeController.themeMode == ThemeMode.system,
            onTap: () => themeController.updateThemeMode(ThemeMode.system),
          ),
          const SizedBox(height: 24),
        ],
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

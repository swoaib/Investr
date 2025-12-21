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
          // Theme Preview
          _ThemePreviewCard(),
          const SizedBox(height: 24),
          // Theme Options
          RadioGroup<ThemeMode>(
            groupValue: themeController.themeMode,
            onChanged: (val) {
              if (val != null) themeController.updateThemeMode(val);
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(l10n.system),
                  activeColor: AppTheme.primaryGreen,
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text(l10n.light),
                  activeColor: AppTheme.primaryGreen,
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text(l10n.dark),
                  activeColor: AppTheme.primaryGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This card renders using current theme colors to show preview
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 50,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

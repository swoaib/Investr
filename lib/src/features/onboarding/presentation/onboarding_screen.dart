import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:investr/l10n/app_localizations.dart';
import 'package:investr/src/features/onboarding/presentation/widgets/notification_simulation_card.dart';
import 'package:investr/src/features/onboarding/presentation/widgets/simplified_learn_widget.dart';
import 'package:investr/src/features/onboarding/presentation/widgets/simplified_stock_widgets.dart';
import 'package:investr/src/features/onboarding/presentation/widgets/simplified_valuation_widget.dart';
import 'package:investr/src/shared/locale/locale_controller.dart';
import 'package:investr/src/shared/theme/theme_controller.dart';
import 'package:provider/provider.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/language_picker.dart';
import 'onboarding_controller.dart';

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
      _LanguageSelectionPage(
        title: l10n.chooseLanguage,
        description: l10n.chooseLanguageDesc,
        imagePath: 'assets/images/onboarding/language_selection.png',
      ),
      _ThemeSelectionPage(
        title: l10n.chooseTheme,
        description: l10n.chooseThemeDesc,
        imagePath: 'assets/images/onboarding/theme_selection.png',
      ),
      _StockTrackingPage(
        title: l10n.trackYourStocks,
        description: l10n.trackYourStocksDesc,
      ),
      _GenericWidgetPage(
        title: l10n.learnToInvest,
        description: l10n.learnToInvestDesc,
        child: const SimplifiedLearnWidget(),
      ),
      _GenericWidgetPage(
        title: l10n.valueYourPortfolio,
        description: l10n.valueYourPortfolioDesc,
        child: const SimplifiedValuationWidget(),
      ),
      _NotificationPermissionPage(
        title: l10n.enableNotificationsTitle,
        description: l10n.enableNotificationsDesc,
        enableButtonText: l10n.enableNotificationsButton,
        notNowButtonText: l10n.notNow,
        onEnable: () async {
          await controller.requestNotificationPermission();
          if (context.mounted) {
            controller.completeOnboarding(context);
            context.go('/');
          }
        },
        onNotNow: () {
          controller.completeOnboarding(context);
          context.go('/');
        },
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
            if (!controller.isLastPage)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    controller.completeOnboarding(context);
                    context.go('/');
                  },
                  child: Text(l10n.skip),
                ),
              )
            else
              const SizedBox(height: 48),
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
                  // Next/Get Started Button (Hide on last page as it has its own buttons)
                  Visibility(
                    visible: !controller.isLastPage,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.nextPage();
                      },
                      child: Text(l10n.next),
                    ),
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
    required this.title,
    required this.description,
    required this.imagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 250),
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

class _StockTrackingPage extends StatefulWidget {
  final String title;
  final String description;

  const _StockTrackingPage({required this.title, required this.description});

  @override
  State<_StockTrackingPage> createState() => _StockTrackingPageState();
}

class _StockTrackingPageState extends State<_StockTrackingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    // Start animation immediately
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SlideTransition(
            position: _offsetAnimation,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SimplifiedStockOverviewCard(),
                SizedBox(width: 16),
                SimplifiedEarningsCard(),
              ],
            ),
          ),
          const Spacer(flex: 2), // Gives more bottom space for the widgets
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 180),
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
            // Language Picker
            LanguagePicker(
              selectedLocale: localeController.locale,
              onLocaleChanged: (val) {
                localeController.updateLocale(val);
              },
            ),
          ],
        ),
      ),
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
          // Theme Preview Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ThemePreviewCard(
                      mode: ThemeMode.light,
                      label: l10n.light,
                      isSelected: themeController.themeMode == ThemeMode.light,
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
                onTap: () => themeController.updateThemeMode(ThemeMode.system),
              ),
            ],
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

class _NotificationPermissionPage extends StatefulWidget {
  final VoidCallback onEnable;
  final VoidCallback onNotNow;

  final String title;
  final String description;
  final String enableButtonText;
  final String notNowButtonText;

  const _NotificationPermissionPage({
    required this.onEnable,
    required this.onNotNow,
    required this.title,
    required this.description,
    required this.enableButtonText,
    required this.notNowButtonText,
  });

  @override
  State<_NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends State<_NotificationPermissionPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          const _SlideUpAnimation(child: NotificationSimulationCard()),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onEnable,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.enableButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onNotNow,
            child: Text(
              widget.notNowButtonText,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _GenericWidgetPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _GenericWidgetPage({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
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
          const Spacer(),
          child,
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _SlideUpAnimation extends StatefulWidget {
  final Widget child;
  const _SlideUpAnimation({required this.child});

  @override
  State<_SlideUpAnimation> createState() => _SlideUpAnimationState();
}

class _SlideUpAnimationState extends State<_SlideUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // Reduced start offset for smoother feel
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(opacity: _controller, child: widget.child),
    );
  }
}

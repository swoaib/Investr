import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:investr/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/alerts/data/alerts_repository.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/market_data/data/stock_repository.dart';
import 'features/market_data/presentation/stock_list_controller.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/settings/presentation/privacy_policy_screen.dart';
import 'shared/currency/currency_controller.dart';
import 'shared/locale/locale_controller.dart';
import 'shared/services/analytics_service.dart';
import 'shared/settings/settings_controller.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_controller.dart';

class InvestrApp extends StatefulWidget {
  final bool onboardingCompleted;
  final SharedPreferences prefs;
  final StockListController? stockListController;
  final StockRepository? stockRepository;
  final ThemeController? themeController;
  final AnalyticsService? analyticsService;

  const InvestrApp({
    required this.onboardingCompleted,
    required this.prefs,
    super.key,
    this.stockListController,
    this.stockRepository,
    this.themeController,
    this.analyticsService,
  });

  @override
  State<InvestrApp> createState() => _InvestrAppState();
}

class _InvestrAppState extends State<InvestrApp> {
  late final GoRouter _router;
  late final AnalyticsService _analyticsService;

  @override
  void initState() {
    super.initState();
    _analyticsService = widget.analyticsService ?? AnalyticsService();
    _router = _buildRouter(widget.onboardingCompleted, _analyticsService);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AnalyticsService>.value(value: _analyticsService),
        Provider<StockRepository>(
          create: (_) => widget.stockRepository ?? StockRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              widget.stockListController ??
              (StockListController(repository: context.read<StockRepository>())
                ..loadStocks()),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) =>
              widget.themeController ?? ThemeController(widget.prefs),
        ),
        ChangeNotifierProvider(create: (_) => SettingsController(widget.prefs)),
        ChangeNotifierProvider(create: (_) => LocaleController(widget.prefs)),
        ChangeNotifierProvider(create: (_) => CurrencyController()),
        Provider<AlertsRepository>(create: (_) => AlertsRepository()),
      ],
      child: Consumer2<ThemeController, LocaleController>(
        builder: (context, themeController, localeController, child) {
          return MaterialApp.router(
            title: 'Investr',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            locale: localeController.locale,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale?.languageCode == 'no') {
                return const Locale('nb');
              }
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

GoRouter _buildRouter(bool onboardingCompleted, AnalyticsService analytics) {
  return GoRouter(
    initialLocation: onboardingCompleted ? '/' : '/onboarding',
    observers: [analytics.observer],
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(
        path: '/settings/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
}

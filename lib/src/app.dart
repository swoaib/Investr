import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_controller.dart';
import 'features/market_data/presentation/stock_list_controller.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

class InvestrApp extends StatefulWidget {
  final bool onboardingCompleted;
  final SharedPreferences prefs;
  final StockListController? stockListController;
  final ThemeController? themeController;

  const InvestrApp({
    super.key,
    required this.onboardingCompleted,
    required this.prefs,
    this.stockListController,
    this.themeController,
  });

  @override
  State<InvestrApp> createState() => _InvestrAppState();
}

class _InvestrAppState extends State<InvestrApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter(widget.onboardingCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              widget.stockListController ??
              (StockListController()..loadStocks()),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) =>
              widget.themeController ?? ThemeController(widget.prefs),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, controller, child) {
          return MaterialApp.router(
            title: 'Investr',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: controller.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

GoRouter _buildRouter(bool onboardingCompleted) {
  return GoRouter(
    initialLocation: onboardingCompleted ? '/' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    ],
  );
}

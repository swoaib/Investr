import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared/theme/app_theme.dart';

// Placeholder screens for routing setup
import 'package:provider/provider.dart';
import 'features/market_data/presentation/stock_list_controller.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

class InvestrApp extends StatelessWidget {
  final bool onboardingCompleted;

  const InvestrApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StockListController()..loadStocks(),
          lazy: false,
        ),
      ],
      child: MaterialApp.router(
        title: 'Investr',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: _buildRouter(onboardingCompleted),
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

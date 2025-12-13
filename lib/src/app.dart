import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared/theme/app_theme.dart';

// Placeholder screens for routing setup
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

class InvestrApp extends StatelessWidget {
  const InvestrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Investr',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation:
      '/onboarding', // Start with onboarding for now, we'll add logic to check if seen later
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
  ],
);

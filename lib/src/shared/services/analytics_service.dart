import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  AnalyticsService._internal() : _analytics = FirebaseAnalytics.instance;

  /// Visible for testing
  AnalyticsService.test(this._analytics);

  final FirebaseAnalytics _analytics;

  NavigatorObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  Future<void> logCalculatorUsage({
    required String symbol,
    required double result,
    required double wacc,
    required double growthRate,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'dcf_calculation',
        parameters: {
          'symbol': symbol,
          'result': result,
          'wacc': wacc,
          'growth_rate': growthRate,
        },
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: false);
      debugPrint('Failed to log DCF usage: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;
  int get currentPage => _currentPage;

  bool _isLastPage = false;
  bool get isLastPage => _isLastPage;

  static const int totalPages = 5;

  void onPageChanged(int index) {
    _currentPage = index;
    _isLastPage = index == totalPages - 1;
    notifyListeners();
  }

  Future<void> completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    // In a real app, you would verify this check in a Splash screen or main initialization
  }

  void nextPage() {
    if (_currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load shared preferences
  final prefs = await SharedPreferences.getInstance();

  // Check if onboarding is completed
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(InvestrApp(onboardingCompleted: onboardingCompleted, prefs: prefs));
}

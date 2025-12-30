import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load shared preferences
  final prefs = await SharedPreferences.getInstance();

  // Check if onboarding is completed
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(InvestrApp(onboardingCompleted: onboardingCompleted, prefs: prefs));
}

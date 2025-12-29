import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Load shared preferences
  final prefs = await SharedPreferences.getInstance();

  // Check if onboarding is completed
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(InvestrApp(onboardingCompleted: onboardingCompleted, prefs: prefs));
}

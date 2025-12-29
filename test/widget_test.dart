import 'package:flutter_test/flutter_test.dart';
import 'package:investr/src/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mocks.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Populate SharedPreferences with mock values
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final mockStockListController = MockStockListController();
    final mockStockRepository = MockStockRepository();
    final mockThemeController = MockThemeController();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      InvestrApp(
        onboardingCompleted: false,
        prefs: prefs,
        stockListController: mockStockListController,
        stockRepository: mockStockRepository,
        themeController: mockThemeController,
      ),
    );
  });
}

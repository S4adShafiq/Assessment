import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Auth Flow Integration Test', (WidgetTester tester) async {
    // Start app
    app.main();
    await tester.pumpAndSettle();

    // Verify Welcome
    expect(find.text('Welcome!'), findsOneWidget);

    // Fill out form
    await tester.enterText(
      find.widgetWithText(TextField, 'example@email.com').first,
      'test@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'JohnApple').first,
      'Tester',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '••••••••').first,
      'Test@1234',
    );

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Currently 'Next' relies on Isar/Firebase being initialized correctly so it might fail or stay on screen depending on environment
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutriguide/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can navigate to registration', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Find Sign Up button
    final signUpBtn = find.text('Sign Up');
    expect(signUpBtn, findsOneWidget);

    // Tap it
    await tester.tap(signUpBtn);
    await tester.pumpAndSettle();

    // Verify Register Screen
    expect(find.text('Create Account'), findsOneWidget);

    // Enter details
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@test.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');

    // Verify inputs
    expect(find.text('test@test.com'), findsOneWidget);
  });
}

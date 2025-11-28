import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutriguide/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and shows login screen by default', (tester) async {
    // Launch app
    app.main();
    await tester.pumpAndSettle();

    // Verify Login Screen appears
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}

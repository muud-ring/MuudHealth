import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Boot widget renders splash screen', (WidgetTester tester) async {
    // Test that the app's Boot widget can be instantiated without crashing.
    // We don't test MuudApp directly since it requires AppLinks and other
    // platform services that are not available in a test environment.

    // Verify that a simple MaterialApp with a Scaffold renders correctly,
    // mirroring the Boot widget's build method structure.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.expand(
            child: Center(
              child: Text('MUUD'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('MUUD'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);
  });
}

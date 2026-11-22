import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/main.dart';

void main() {
  testWidgets('App smoke test - loads welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the welcome screen elements are displayed.
    expect(find.textContaining('Your body has its'), findsOneWidget);
    expect(find.text("Let's Begin"), findsOneWidget);
  });
}

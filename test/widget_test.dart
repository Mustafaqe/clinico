import 'package:flutter_test/flutter_test.dart';

import 'package:clinico/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClinicoApp());

    // Verify that the app loads with the dashboard.
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Clinico'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:asha_application/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App should start with login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts with the login page
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });

  testWidgets('App should have proper theme', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that the app has the correct title
    expect(find.text('خدمات المناسبات'), findsOneWidget);
  });
}

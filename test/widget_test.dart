// This is a basic Flutter widget test for MuzikaApp.

import 'package:flutter_test/flutter_test.dart';

import 'package:muzika/main.dart';

void main() {
  testWidgets('Muzika app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MuzikaApp());

    // Verify that the initial empty state placeholder is present.
    expect(find.text('Search for any song\nto get started'), findsOneWidget);
  });
}

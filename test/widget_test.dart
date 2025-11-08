import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inf281_app/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

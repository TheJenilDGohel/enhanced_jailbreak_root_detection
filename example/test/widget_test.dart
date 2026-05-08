import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enhanced_jailbreak_root_detection_example/main.dart';

void main() {
  testWidgets('Verify App Launches', (WidgetTester tester) async {
    // We just want to make sure the app doesn't crash on startup during our test.
    // The previous test expected 'Running on:' which was removed from main.dart
    await tester.pumpWidget(const MyApp());
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}

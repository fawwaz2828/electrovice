// This is a basic Flutter widget test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electrovice/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ElectroviceApp());

    // Verify that the app title is present or just that it loads without crashing
    expect(find.byType(MaterialApp), findsWidgets);
  });
}

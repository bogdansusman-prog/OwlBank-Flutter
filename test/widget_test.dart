// Basic smoke test: makes sure the app boots and lands on the login
// screen (the initial route), without needing a backend connection.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:owlbank_flutter/main.dart';

void main() {
  testWidgets('App boots and shows the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OwlBankApp());
    await tester.pump();

    expect(find.text('OwlBank'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

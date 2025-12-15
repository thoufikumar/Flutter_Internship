import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker_app/auth/auth_gate.dart';
import 'package:expense_tracker_app/provider/ExpenseProvider.dart';
import 'package:expense_tracker_app/provider/currency_provider.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ],
        child: const MaterialApp(
          home: AuthGate(),
        ),
      ),
    );

    // Just verify app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

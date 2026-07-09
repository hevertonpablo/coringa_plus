import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builds a minimal Material shell', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('Coringa Plus')),
      ),
    );

    expect(find.text('Coringa Plus'), findsOneWidget);
  });
}

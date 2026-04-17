import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders Leftover Roulette text', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Leftover Roulette')),
      ),
    ));

    expect(find.text('Leftover Roulette'), findsOneWidget);
  });
}

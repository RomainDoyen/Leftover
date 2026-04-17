import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leftover_roulette/presentation/theme/app_theme.dart';
import 'package:leftover_roulette/presentation/screens/home/home_screen.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HomeScreen(),
        ),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Leftover Roulette'), findsOneWidget);
  });
}

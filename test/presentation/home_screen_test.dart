// test/presentation/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leftover_roulette/presentation/screens/home/home_screen.dart';

void main() {
  group('HomeScreen', () {
    Widget buildSubject() => const ProviderScope(
          child: MaterialApp(home: HomeScreen()),
        );

    testWidgets('renders title and spin button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Leftover Roulette'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);

      // Scroll until the spin button is built and visible
      await tester.scrollUntilVisible(
        find.text('Spin the Roulette'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      // Scroll a bit more so the button centre is fully inside the viewport
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -80));
      await tester.pump();
      expect(find.text('Spin the Roulette'), findsOneWidget);
    });

    testWidgets('adding ingredient creates a chip', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'oignon');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('oignon'), findsOneWidget);
    });

    testWidgets('duplicate ingredients are not added', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'oignon');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'oignon');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Only one chip for 'oignon'
      expect(find.text('oignon'), findsOneWidget);
    });

    testWidgets('spin shows snackbar when no ingredients', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Scroll until button is built, then scroll extra so its centre is
      // fully inside the 800×600 test viewport before tapping.
      await tester.scrollUntilVisible(
        find.text('Spin the Roulette'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -80));
      await tester.pump();

      await tester.tap(find.text('Spin the Roulette'));
      await tester.pump();

      expect(
        find.text('Ajoute au moins un ingrédient !'),
        findsOneWidget,
      );
    });
  });
}

// test/presentation/match_ring_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leftover_roulette/presentation/screens/result/widgets/match_ring.dart';

void main() {
  group('MatchRing', () {
    Widget buildSubject(double score) => MaterialApp(
          home: Scaffold(body: MatchRing(score: score)),
        );

    testWidgets('renders without error for score 0.0', (tester) async {
      await tester.pumpWidget(buildSubject(0.0));
      expect(find.byType(MatchRing), findsOneWidget);
    });

    testWidgets('renders without error for score 1.0', (tester) async {
      await tester.pumpWidget(buildSubject(1.0));
      expect(find.byType(MatchRing), findsOneWidget);
    });

    testWidgets('clamps scores above 1.0', (tester) async {
      // Should not crash or throw with out-of-range score
      await tester.pumpWidget(buildSubject(1.5));
      expect(find.byType(MatchRing), findsOneWidget);
    });
  });
}

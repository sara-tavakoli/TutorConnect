import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/features/reviews/widgets/star_rating.dart';

void main() {
  group('StarRating — rendering', () {
    testWidgets('renders exactly 5 star icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StarRating(value: 3)),
        ),
      );
      // 3 filled + 2 outline = 5 total
      final stars = find.byWidgetPredicate((w) =>
          w is Icon &&
          (w.icon == Icons.star_rounded ||
              w.icon == Icons.star_outline_rounded));
      expect(stars, findsNWidgets(5));
    });

    testWidgets('correct number of filled stars for given value',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StarRating(value: 4)),
        ),
      );
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(1));
    });

    testWidgets('all stars outlined when value is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StarRating(value: 0)),
        ),
      );
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('all stars filled when value is 5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StarRating(value: 5)),
        ),
      );
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    });
  });

  group('StarRating — interactions', () {
    testWidgets('calls onChanged with correct value when star is tapped',
        (tester) async {
      double? selected;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRating(
            value: 0,
            onChanged: (v) => selected = v,
          ),
        ),
      ));

      // Tap the 4th star (index 3 → value 4)
      final stars = find.byWidgetPredicate((w) =>
          w is Icon &&
          (w.icon == Icons.star_rounded ||
              w.icon == Icons.star_outline_rounded));
      await tester.tap(stars.at(3));
      expect(selected, 4.0);
    });

    testWidgets('tapping first star selects 1', (tester) async {
      double? selected;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRating(
            value: 0,
            onChanged: (v) => selected = v,
          ),
        ),
      ));

      final stars = find.byWidgetPredicate((w) =>
          w is Icon &&
          (w.icon == Icons.star_rounded ||
              w.icon == Icons.star_outline_rounded));
      await tester.tap(stars.at(0));
      expect(selected, 1.0);
    });

    testWidgets('does not call onChanged when onChanged is null',
        (tester) async {
      // Should not throw
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StarRating(value: 3)),
        ),
      );
      final stars = find.byWidgetPredicate((w) =>
          w is Icon &&
          (w.icon == Icons.star_rounded ||
              w.icon == Icons.star_outline_rounded));
      await tester.tap(stars.at(0), warnIfMissed: false);
      // No exception means the test passes
    });
  });

  group('StarDisplay — rendering', () {
    testWidgets('displays rating and review count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarDisplay(rating: 4.5, reviewCount: 12),
          ),
        ),
      );
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(12)'), findsOneWidget);
    });
  });
}

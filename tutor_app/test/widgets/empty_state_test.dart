import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/core/widgets/empty_state.dart';

void main() {
  Widget build({
    IconData icon = Icons.search_off_rounded,
    String title = 'Nothing here',
    String message = 'Try again later.',
    String? buttonLabel,
    VoidCallback? onButtonTap,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: icon,
            title: title,
            message: message,
            buttonLabel: buttonLabel,
            onButtonTap: onButtonTap,
          ),
        ),
      );

  group('EmptyState — rendering', () {
    testWidgets('displays title and message', (tester) async {
      await tester.pumpWidget(build(
        title: 'No tutors found',
        message: 'Try a different subject.',
      ));
      expect(find.text('No tutors found'), findsOneWidget);
      expect(find.text('Try a different subject.'), findsOneWidget);
    });

    testWidgets('renders provided icon', (tester) async {
      await tester.pumpWidget(
          build(icon: Icons.calendar_today_rounded));
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
    });

    testWidgets('shows action button when buttonLabel is provided',
        (tester) async {
      await tester.pumpWidget(
          build(buttonLabel: 'Clear filter', onButtonTap: () {}));
      expect(find.text('Clear filter'), findsOneWidget);
    });

    testWidgets('hides action button when buttonLabel is null',
        (tester) async {
      await tester.pumpWidget(build());
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });

  group('EmptyState — interactions', () {
    testWidgets('calls onButtonTap when action button is tapped',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(build(
        buttonLabel: 'Clear filter',
        onButtonTap: () => tapped = true,
      ));
      await tester.tap(find.text('Clear filter'));
      expect(tapped, isTrue);
    });
  });
}

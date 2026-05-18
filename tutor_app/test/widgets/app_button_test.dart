import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/core/widgets/app_button.dart';

void main() {
  Widget build({
    String label = 'Submit',
    VoidCallback? onPressed,
    bool isLoading = false,
    AppButtonVariant variant = AppButtonVariant.primary,
    IconData? icon,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: label,
            onPressed: onPressed,
            isLoading: isLoading,
            variant: variant,
            icon: icon,
          ),
        ),
      );

  group('AppButton — rendering', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(build(label: 'Sign In', onPressed: () {}));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(build(isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('renders icon when icon is provided', (tester) async {
      await tester.pumpWidget(
          build(icon: Icons.save_rounded, onPressed: () {}));
      expect(find.byIcon(Icons.save_rounded), findsOneWidget);
    });

    testWidgets('outlined variant renders OutlinedButton', (tester) async {
      await tester.pumpWidget(
          build(variant: AppButtonVariant.outlined, onPressed: () {}));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('ghost variant renders TextButton', (tester) async {
      await tester.pumpWidget(
          build(variant: AppButtonVariant.ghost, onPressed: () {}));
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  group('AppButton — interactions', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(build(onPressed: () => tapped = true));
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when button is disabled',
        (tester) async {
      var tapped = false;
      // onPressed: null disables the button
      await tester.pumpWidget(build(onPressed: null));
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('does not call onPressed when isLoading is true',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
          build(onPressed: () => tapped = true, isLoading: true));
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });
  });
}

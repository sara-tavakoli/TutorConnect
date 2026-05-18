import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/core/widgets/app_text_field.dart';

void main() {
  Widget build({
    String label = 'Email',
    String? hint,
    bool isPassword = false,
    TextEditingController? controller,
    FormFieldValidator<String>? validator,
  }) {
    final ctrl = controller ?? TextEditingController();
    return MaterialApp(
      home: Scaffold(
        body: Form(
          child: AppTextField(
            label: label,
            hint: hint,
            controller: ctrl,
            isPassword: isPassword,
            validator: validator,
          ),
        ),
      ),
    );
  }

  group('AppTextField — rendering', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(build(label: 'Full name'));
      expect(find.text('Full name'), findsOneWidget);
    });

    testWidgets('shows hint text inside field', (tester) async {
      await tester.pumpWidget(build(hint: 'you@example.com'));
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('password field obscures text by default', (tester) async {
      await tester.pumpWidget(build(isPassword: true));
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('non-password field does not obscure text', (tester) async {
      await tester.pumpWidget(build(isPassword: false));
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });
  });

  group('AppTextField — password visibility toggle', () {
    testWidgets('tapping eye icon reveals password', (tester) async {
      await tester.pumpWidget(build(isPassword: true));

      // Initially obscured
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText,
          isTrue);

      // Tap the visibility icon
      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pump();

      // Now revealed
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText,
          isFalse);
    });

    testWidgets('tapping eye icon again re-hides password', (tester) async {
      await tester.pumpWidget(build(isPassword: true));

      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_rounded));
      await tester.pump();

      expect(tester.widget<TextField>(find.byType(TextField)).obscureText,
          isTrue);
    });
  });

  group('AppTextField — validation', () {
    testWidgets('shows validator error message when field is invalid',
        (tester) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: key,
            child: Column(children: [
              AppTextField(
                label: 'Email',
                controller: TextEditingController(),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Email is required.' : null,
              ),
              ElevatedButton(
                onPressed: () => key.currentState!.validate(),
                child: const Text('Validate'),
              ),
            ]),
          ),
        ),
      ));

      await tester.tap(find.text('Validate'));
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);
    });
  });
}

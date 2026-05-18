import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tutorconnect/features/auth/providers/auth_provider.dart';
import 'package:tutorconnect/features/auth/screens/register_screen.dart';
import 'package:tutorconnect/services/auth_service.dart';

Widget buildScreen(AuthProvider auth) => MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: const RegisterScreen(),
      ),
    );

AuthProvider makeProvider() => AuthProvider(
      service: AuthService(
        auth: MockFirebaseAuth(),
        db: FakeFirebaseFirestore(),
      ),
    );

Future<void> useTallCanvas(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  group('RegisterScreen — rendering', () {
    testWidgets('shows Create account heading', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Create account'), findsOneWidget);
    });

    testWidgets('shows all form field labels', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
    });

    testWidgets('shows Student and Tutor role options', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Tutor'), findsOneWidget);
    });

    testWidgets('shows Create Account button', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Create Account'), findsOneWidget);
    });
  });

  group('RegisterScreen — role selection', () {
    testWidgets('Student is selected by default', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Find tutors & book sessions'), findsOneWidget);
    });

    testWidgets('tapping Tutor card changes the selection description',
        (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      await tester.tap(find.text('Tutor'));
      await tester.pump();
      expect(find.text('Offer your skills & earn'), findsOneWidget);
    });
  });

  group('RegisterScreen — form validation', () {
    testWidgets('shows name error when name is empty', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Name is required.'), findsOneWidget);
    });

    testWidgets('shows email error when name filled but email empty',
        (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(0), 'Jane Smith');
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);
    });

    testWidgets('shows mismatch error when passwords differ', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Jane Smith');
      await tester.enterText(fields.at(1), 'jane@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'different456');

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('shows length error for password shorter than 6 chars',
        (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Jane Smith');
      await tester.enterText(fields.at(1), 'jane@example.com');
      await tester.enterText(fields.at(2), '123');
      await tester.enterText(fields.at(3), '123');

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Minimum 6 characters.'), findsOneWidget);
    });
  });

  group('RegisterScreen — successful registration', () {
    testWidgets('shows welcome snackbar after valid signup', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Jane Smith');
      await tester.enterText(fields.at(1), 'jane@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Welcome! Your account has been created.'),
        findsOneWidget,
      );
    });
  });
}

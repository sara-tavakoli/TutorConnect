import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tutorconnect/features/auth/providers/auth_provider.dart';
import 'package:tutorconnect/features/auth/screens/login_screen.dart';
import 'package:tutorconnect/services/auth_service.dart';

Widget buildScreen(AuthProvider auth) => ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: const MaterialApp(home: LoginScreen()),
    );

AuthProvider makeProvider() => AuthProvider(
      service: AuthService(
        auth: MockFirebaseAuth(),
        db: FakeFirebaseFirestore(),
      ),
    );

// Give the test a tall canvas so all scrollable content is reachable
Future<void> useTallCanvas(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  group('LoginScreen — rendering', () {
    testWidgets('shows email and password field labels', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows Sign In button', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows Forgot password link', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('shows Create an account link', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Create an account'), findsOneWidget);
    });
  });

  group('LoginScreen — form validation', () {
    testWidgets('shows error when email is empty on submit', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'notanemail');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Enter a valid email.'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'valid@example.com');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Password is required.'), findsOneWidget);
    });

    testWidgets('no validation errors shown on initial render', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();
      expect(find.text('Email is required.'), findsNothing);
      expect(find.text('Password is required.'), findsNothing);
    });
  });

  group('LoginScreen — navigation', () {
    testWidgets('Create an account link opens RegisterScreen', (tester) async {
      await useTallCanvas(tester);
      await tester.pumpWidget(buildScreen(makeProvider()));
      await tester.pump();

      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();

      // RegisterScreen shows the 'Create account' heading
      expect(find.text('Create account'), findsWidgets);
    });
  });
}

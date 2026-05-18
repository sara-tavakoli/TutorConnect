import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tutorconnect/features/auth/providers/auth_provider.dart';
import 'package:tutorconnect/features/profile/screens/profile_screen.dart';
import 'package:tutorconnect/models/user_model.dart';
import 'package:tutorconnect/services/auth_service.dart';

// Minimal AuthProvider stub that starts pre-authenticated.
class _FakeAuthProvider extends AuthProvider {
  final UserModel _fakeUser;
  _FakeAuthProvider(this._fakeUser)
      : super(
          service: AuthService(
            auth: MockFirebaseAuth(),
            db: FakeFirebaseFirestore(),
          ),
        );

  @override
  UserModel? get user => _fakeUser;

  @override
  AuthStatus get status => AuthStatus.authenticated;

  @override
  bool get isAuth => true;
}

final _student = UserModel(
  uid: 'student1',
  name: 'Jane Smith',
  email: 'jane@example.com',
  role: UserRole.student,
  createdAt: DateTime(2024),
);

// Note: tutor user triggers _ProfileHeader._loadPhoto() which calls TutorService()
// directly (no DI). That requires real Firebase, so tutor-specific tests use
// the student role with a custom name to avoid the Firebase initialisation error.
Widget buildScreen(UserModel user) => ChangeNotifierProvider<AuthProvider>.value(
      value: _FakeAuthProvider(user),
      child: const MaterialApp(home: ProfileScreen()),
    );

void main() {
  group('ProfileScreen — student view', () {
    testWidgets('shows Profile heading', (tester) async {
      await tester.pumpWidget(buildScreen(_student));
      await tester.pump();
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('shows student name', (tester) async {
      await tester.pumpWidget(buildScreen(_student));
      await tester.pump();
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('shows student email', (tester) async {
      await tester.pumpWidget(buildScreen(_student));
      await tester.pump();
      // Email can appear in both the header and a label — accept any occurrence
      expect(find.text('jane@example.com'), findsWidgets);
    });

    testWidgets('shows Student account role badge', (tester) async {
      await tester.pumpWidget(buildScreen(_student));
      await tester.pump();
      expect(find.text('Student account'), findsOneWidget);
    });

    testWidgets('does not show Edit Tutor Profile for student', (tester) async {
      await tester.pumpWidget(buildScreen(_student));
      await tester.pump();
      expect(find.text('Edit Tutor Profile'), findsNothing);
    });
  });

  group('ProfileScreen — sign out interaction', () {
    testWidgets('tapping logout icon shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildScreen(_student));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('tapping Cancel dismisses the sign-out dialog', (tester) async {
      await tester.pumpWidget(buildScreen(_student));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out'), findsNothing);
    });
  });
}

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/features/auth/providers/auth_provider.dart';
import 'package:tutorconnect/models/user_model.dart';
import 'package:tutorconnect/services/auth_service.dart';

void main() {
  late FakeFirebaseFirestore fakeDb;
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUp(() {
    fakeDb = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth, db: fakeDb);
  });

  AuthProvider buildProvider() => AuthProvider(service: authService);

  group('AuthProvider — initial state', () {
    test('starts as unknown while stream is pending', () {
      final provider = buildProvider();
      expect(provider.status, AuthStatus.unknown);
      expect(provider.user, isNull);
      expect(provider.isAuth, isFalse);
      expect(provider.isLoading, isFalse);
    });

    test('transitions to unauthenticated when no user is signed in', () async {
      final provider = buildProvider();
      await Future.delayed(Duration.zero);
      expect(provider.status, AuthStatus.unauthenticated);
    });
  });

  group('AuthProvider.register', () {
    test('returns true and sets authenticated status on success', () async {
      final provider = buildProvider();
      final result = await provider.register(
        name: 'Jane Smith',
        email: 'jane@example.com',
        password: 'password123',
        role: UserRole.student,
      );

      expect(result, isTrue);
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.user, isNotNull);
      expect(provider.user!.name, 'Jane Smith');
      expect(provider.errorMessage, isNull);
    });

    test('sets isLoading to false after completion', () async {
      final provider = buildProvider();
      await provider.register(
        name: 'Jane',
        email: 'jane@example.com',
        password: 'pass123',
        role: UserRole.student,
      );
      expect(provider.isLoading, isFalse);
    });
  });

  group('AuthProvider.signIn', () {
    test('returns true and sets user after valid registration + sign-in',
        () async {
      // First register so the user exists
      final registerProvider = AuthProvider(service: authService);
      await registerProvider.register(
        name: 'Jane',
        email: 'jane@example.com',
        password: 'password123',
        role: UserRole.student,
      );

      // Now sign in with a fresh provider using the same services
      final signInProvider = AuthProvider(service: authService);
      final result = await signInProvider.signIn(
        email: 'jane@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(signInProvider.isAuth, isTrue);
    });
  });

  group('AuthProvider.signOut', () {
    test('clears user and sets unauthenticated', () async {
      final provider = buildProvider();
      await provider.register(
        name: 'Jane',
        email: 'jane@example.com',
        password: 'pass123',
        role: UserRole.student,
      );
      expect(provider.isAuth, isTrue);

      await provider.signOut();

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.user, isNull);
    });
  });

  group('AuthProvider — clearError', () {
    test('clearError keeps errorMessage null when already null', () {
      final provider = buildProvider();
      expect(provider.errorMessage, isNull);
      provider.clearError();
      expect(provider.errorMessage, isNull);
    });

    test('isLoading starts false', () {
      final provider = buildProvider();
      expect(provider.isLoading, isFalse);
    });
  });
}

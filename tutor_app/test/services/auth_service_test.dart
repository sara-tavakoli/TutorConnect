import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/models/user_model.dart';
import 'package:tutorconnect/services/auth_service.dart';

void main() {
  late FakeFirebaseFirestore fakeDb;
  late MockFirebaseAuth mockAuth;
  late AuthService service;

  setUp(() {
    fakeDb = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    service = AuthService(auth: mockAuth, db: fakeDb);
  });

  group('AuthService.register', () {
    test('creates a user document in Firestore', () async {
      final user = await service.register(
        name: 'Jane Smith',
        email: 'jane@example.com',
        password: 'password123',
        role: UserRole.student,
      );

      expect(user.name, 'Jane Smith');
      expect(user.email, 'jane@example.com');
      expect(user.role, UserRole.student);

      final doc = await fakeDb.collection('users').doc(user.uid).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], 'Jane Smith');
    });

    test('creates a tutor document for tutor role', () async {
      final user = await service.register(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
        role: UserRole.tutor,
      );

      final tutorDoc =
          await fakeDb.collection('tutors').doc(user.uid).get();
      expect(tutorDoc.exists, isTrue);
      expect(tutorDoc.data()!['name'], 'John Doe');
    });

    test('does not create tutor document for student role', () async {
      final user = await service.register(
        name: 'Jane Smith',
        email: 'jane@example.com',
        password: 'password123',
        role: UserRole.student,
      );

      final tutorDoc =
          await fakeDb.collection('tutors').doc(user.uid).get();
      expect(tutorDoc.exists, isFalse);
    });
  });

  group('AuthService.fetchUser', () {
    test('returns UserModel when user exists', () async {
      final registered = await service.register(
        name: 'Jane',
        email: 'jane@example.com',
        password: 'pass123',
        role: UserRole.student,
      );

      final fetched = await service.fetchUser(registered.uid);
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Jane');
    });

    test('returns null when user does not exist', () async {
      final result = await service.fetchUser('nonexistent-uid');
      expect(result, isNull);
    });
  });

  group('AuthService.authStateChanges', () {
    test('emits a stream', () {
      expect(service.authStateChanges, isA<Stream>());
    });
  });
}

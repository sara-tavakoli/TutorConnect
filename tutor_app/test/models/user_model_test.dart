import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/models/user_model.dart';

void main() {
  final createdAt = DateTime(2024, 6, 1, 12);

  final Map<String, dynamic> studentMap = {
    'name': 'Jane Smith',
    'email': 'jane@uni.edu',
    'role': 'student',
    'photoUrl': null,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  final Map<String, dynamic> tutorMap = {
    'name': 'John Doe',
    'email': 'john@uni.edu',
    'role': 'tutor',
    'photoUrl': 'https://example.com/photo.jpg',
    'createdAt': Timestamp.fromDate(createdAt),
  };

  group('UserModel.fromMap', () {
    test('creates student correctly', () {
      final model = UserModel.fromMap(studentMap, 'uid-1');
      expect(model.uid, 'uid-1');
      expect(model.name, 'Jane Smith');
      expect(model.email, 'jane@uni.edu');
      expect(model.role, UserRole.student);
      expect(model.photoUrl, isNull);
      expect(model.createdAt, createdAt);
    });

    test('creates tutor correctly', () {
      final model = UserModel.fromMap(tutorMap, 'uid-2');
      expect(model.role, UserRole.tutor);
      expect(model.photoUrl, 'https://example.com/photo.jpg');
    });

    test('defaults unknown role to student', () {
      final model = UserModel.fromMap({...studentMap, 'role': 'unknown'}, 'u');
      expect(model.role, UserRole.student);
    });
  });

  group('UserModel.toMap', () {
    test('serialises all fields', () {
      final model = UserModel(
        uid: 'uid-1',
        name: 'Jane Smith',
        email: 'jane@uni.edu',
        role: UserRole.student,
        createdAt: createdAt,
      );
      final map = model.toMap();
      expect(map['name'], 'Jane Smith');
      expect(map['email'], 'jane@uni.edu');
      expect(map['role'], 'student');
      expect(map['photoUrl'], isNull);
      expect((map['createdAt'] as Timestamp).toDate(), createdAt);
    });

    test('round-trips through fromMap', () {
      final original = UserModel.fromMap(tutorMap, 'uid-2');
      final restored = UserModel.fromMap(original.toMap(), 'uid-2');
      expect(restored.name, original.name);
      expect(restored.role, original.role);
      expect(restored.photoUrl, original.photoUrl);
    });
  });

  group('UserModel role getters', () {
    test('isStudent is true only for student', () {
      final student = UserModel.fromMap(studentMap, 'u1');
      expect(student.isStudent, isTrue);
      expect(student.isTutor, isFalse);
    });

    test('isTutor is true only for tutor', () {
      final tutor = UserModel.fromMap(tutorMap, 'u2');
      expect(tutor.isTutor, isTrue);
      expect(tutor.isStudent, isFalse);
    });
  });

  group('UserModel.copyWith', () {
    test('updates name only', () {
      final model = UserModel.fromMap(studentMap, 'u1');
      final copy = model.copyWith(name: 'Updated Name');
      expect(copy.name, 'Updated Name');
      expect(copy.email, model.email);
      expect(copy.uid, model.uid);
    });

    test('updates photoUrl only', () {
      final model = UserModel.fromMap(studentMap, 'u1');
      final copy = model.copyWith(photoUrl: 'https://new.url/pic.png');
      expect(copy.photoUrl, 'https://new.url/pic.png');
      expect(copy.name, model.name);
    });
  });
}

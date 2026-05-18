import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/models/review_model.dart';

void main() {
  final createdAt = DateTime(2024, 6, 15, 10, 30);

  final Map<String, dynamic> reviewMap = {
    'tutorId': 't1',
    'studentId': 's1',
    'studentName': 'Jane Student',
    'rating': 4.5,
    'comment': 'Very helpful!',
    'createdAt': Timestamp.fromDate(createdAt),
  };

  group('ReviewModel.fromMap', () {
    test('parses all fields correctly', () {
      final r = ReviewModel.fromMap(reviewMap, 'r1');
      expect(r.id, 'r1');
      expect(r.tutorId, 't1');
      expect(r.studentId, 's1');
      expect(r.studentName, 'Jane Student');
      expect(r.rating, 4.5);
      expect(r.comment, 'Very helpful!');
      expect(r.createdAt, createdAt);
    });

    test('parses integer rating as double', () {
      final r = ReviewModel.fromMap({...reviewMap, 'rating': 5}, 'r2');
      expect(r.rating, 5.0);
      expect(r.rating, isA<double>());
    });
  });

  group('ReviewModel.toMap', () {
    test('serialises all fields', () {
      final r = ReviewModel.fromMap(reviewMap, 'r1');
      final map = r.toMap();
      expect(map['tutorId'], 't1');
      expect(map['studentId'], 's1');
      expect(map['rating'], 4.5);
      expect(map['comment'], 'Very helpful!');
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('round-trips through fromMap', () {
      final original = ReviewModel.fromMap(reviewMap, 'r1');
      final restored = ReviewModel.fromMap(original.toMap(), 'r1');
      expect(restored.tutorId, original.tutorId);
      expect(restored.rating, original.rating);
      expect(restored.comment, original.comment);
    });
  });
}

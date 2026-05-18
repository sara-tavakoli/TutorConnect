import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/models/tutor_model.dart';

void main() {
  final Map<String, dynamic> fullMap = {
    'name': 'Alice',
    'photoUrl': 'https://example.com/alice.jpg',
    'bio': 'Great maths tutor',
    'subjects': ['Math', 'Physics'],
    'hourlyRate': 45.0,
    'availability': ['Mon 2pm', 'Wed 4pm'],
    'rating': 4.8,
    'reviewCount': 12,
    'university': 'MQ',
    'year': '3rd',
    'latitude': -33.8688,
    'longitude': 151.2093,
    'bookedSlots': ['Mon 2pm'],
  };

  group('TutorModel.fromMap', () {
    test('parses all fields correctly', () {
      final t = TutorModel.fromMap(fullMap, 't1');
      expect(t.uid, 't1');
      expect(t.name, 'Alice');
      expect(t.subjects, ['Math', 'Physics']);
      expect(t.hourlyRate, 45.0);
      expect(t.availability, ['Mon 2pm', 'Wed 4pm']);
      expect(t.rating, 4.8);
      expect(t.reviewCount, 12);
      expect(t.latitude, -33.8688);
      expect(t.longitude, 151.2093);
      expect(t.bookedSlots, ['Mon 2pm']);
    });

    test('defaults missing fields to empty/zero', () {
      final t = TutorModel.fromMap({
        'name': 'Bob',
      }, 't2');
      expect(t.bio, '');
      expect(t.subjects, isEmpty);
      expect(t.availability, isEmpty);
      expect(t.bookedSlots, isEmpty);
      expect(t.hourlyRate, 0.0);
      expect(t.rating, 0.0);
      expect(t.reviewCount, 0);
      expect(t.latitude, isNull);
      expect(t.longitude, isNull);
    });
  });

  group('TutorModel.hasLocation', () {
    test('returns false when lat/lng are null', () {
      final t = TutorModel.fromMap({'name': 'Bob'}, 't2');
      expect(t.hasLocation, isFalse);
    });

    test('returns true when both lat and lng are set', () {
      final t = TutorModel.fromMap(fullMap, 't1');
      expect(t.hasLocation, isTrue);
    });
  });

  group('TutorModel.toMap', () {
    test('serialises bookedSlots', () {
      final t = TutorModel.fromMap(fullMap, 't1');
      final map = t.toMap();
      expect(map['bookedSlots'], ['Mon 2pm']);
    });

    test('round-trips through fromMap', () {
      final original = TutorModel.fromMap(fullMap, 't1');
      final restored = TutorModel.fromMap(original.toMap(), 't1');
      expect(restored.name, original.name);
      expect(restored.subjects, original.subjects);
      expect(restored.bookedSlots, original.bookedSlots);
    });
  });

  group('TutorModel.copyWith', () {
    test('updates hourlyRate only', () {
      final t = TutorModel.fromMap(fullMap, 't1');
      final copy = t.copyWith(hourlyRate: 60.0);
      expect(copy.hourlyRate, 60.0);
      expect(copy.name, t.name);
      expect(copy.uid, t.uid);
    });

    test('updates subjects list', () {
      final t = TutorModel.fromMap(fullMap, 't1');
      final copy = t.copyWith(subjects: ['Chemistry']);
      expect(copy.subjects, ['Chemistry']);
      expect(copy.availability, t.availability);
    });
  });
}

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/services/tutor_service.dart';

void main() {
  late FakeFirebaseFirestore fakeDb;
  late TutorService service;

  setUp(() {
    fakeDb = FakeFirebaseFirestore();
    service = TutorService(db: fakeDb);
  });

  Future<void> seedTutor(String uid, Map<String, dynamic> data) =>
      fakeDb.collection('tutors').doc(uid).set(data);

  final tutorData = {
    'name': 'Alice',
    'bio': 'Maths expert',
    'subjects': ['Math', 'Physics'],
    'hourlyRate': 40.0,
    'availability': ['Mon 2pm'],
    'bookedSlots': <String>[],
    'rating': 4.5,
    'reviewCount': 10,
    'photoUrl': null,
    'university': 'MQ',
    'year': '3rd',
    'latitude': null,
    'longitude': null,
  };

  group('TutorService.getTutors', () {
    test('streams all tutors in the collection', () async {
      await seedTutor('t1', tutorData);
      await seedTutor('t2', {...tutorData, 'name': 'Bob'});

      final tutors = await service.getTutors().first;
      expect(tutors.length, 2);
      expect(tutors.map((t) => t.name), containsAll(['Alice', 'Bob']));
    });

    test('streams empty list when collection is empty', () async {
      final tutors = await service.getTutors().first;
      expect(tutors, isEmpty);
    });
  });

  group('TutorService.getTutorById', () {
    test('returns tutor when document exists', () async {
      await seedTutor('t1', tutorData);
      final tutor = await service.getTutorById('t1');
      expect(tutor, isNotNull);
      expect(tutor!.name, 'Alice');
    });

    test('returns null when document does not exist', () async {
      final tutor = await service.getTutorById('nonexistent');
      expect(tutor, isNull);
    });
  });

  group('TutorService.updateTutor', () {
    test('persists changed fields to Firestore', () async {
      await seedTutor('t1', tutorData);
      final original = await service.getTutorById('t1');
      final updated = original!.copyWith(hourlyRate: 60.0);

      await service.updateTutor(updated);

      final fetched = await service.getTutorById('t1');
      expect(fetched!.hourlyRate, 60.0);
      expect(fetched.name, 'Alice');
    });
  });

  group('TutorService.deleteTutor', () {
    test('removes the document', () async {
      await seedTutor('t1', tutorData);
      await service.deleteTutor('t1');
      final tutor = await service.getTutorById('t1');
      expect(tutor, isNull);
    });
  });
}

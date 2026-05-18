import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/models/review_model.dart';
import 'package:tutorconnect/services/review_service.dart';

void main() {
  late FakeFirebaseFirestore fakeDb;
  late ReviewService service;

  setUp(() {
    fakeDb = FakeFirebaseFirestore();
    service = ReviewService(db: fakeDb);
  });

  ReviewModel makeReview({
    String studentId = 's1',
    double rating = 4.0,
    String comment = 'Great!',
  }) =>
      ReviewModel(
        id: '',
        tutorId: 't1',
        studentId: studentId,
        studentName: 'Jane',
        rating: rating,
        comment: comment,
        createdAt: DateTime(2024, 6, 1),
      );

  Future<void> seedTutor() => fakeDb.collection('tutors').doc('t1').set({
        'name': 'John',
        'rating': 0.0,
        'reviewCount': 0,
      });

  group('ReviewService.addReview', () {
    test('creates review document in subcollection', () async {
      await seedTutor();
      await service.addReview(makeReview());

      final reviews = await fakeDb
          .collection('tutors')
          .doc('t1')
          .collection('reviews')
          .get();
      expect(reviews.docs.length, 1);
      expect(reviews.docs.first.data()['comment'], 'Great!');
    });

    test('updates tutor rating after first review', () async {
      await seedTutor();
      await service.addReview(makeReview(rating: 4.0));

      final tutor = await fakeDb.collection('tutors').doc('t1').get();
      expect(tutor.data()!['rating'], 4.0);
      expect(tutor.data()!['reviewCount'], 1);
    });

    test('recalculates average rating after multiple reviews', () async {
      await seedTutor();
      await service.addReview(makeReview(studentId: 's1', rating: 4.0));
      await service.addReview(makeReview(studentId: 's2', rating: 5.0));

      final tutor = await fakeDb.collection('tutors').doc('t1').get();
      expect(tutor.data()!['rating'], 4.5);
      expect(tutor.data()!['reviewCount'], 2);
    });
  });

  group('ReviewService.getReviews', () {
    test('streams reviews for the correct tutor', () async {
      await seedTutor();
      await service.addReview(makeReview());

      final reviews = await service.getReviews('t1').first;
      expect(reviews.length, 1);
      expect(reviews.first.comment, 'Great!');
    });

    test('returns empty list when no reviews exist', () async {
      final reviews = await service.getReviews('t1').first;
      expect(reviews, isEmpty);
    });
  });

  group('ReviewService.deleteReview', () {
    test('removes the review document', () async {
      await seedTutor();
      await service.addReview(makeReview(studentId: 's1', rating: 4.0));
      final before = await fakeDb
          .collection('tutors').doc('t1').collection('reviews').get();
      final reviewId = before.docs.first.id;

      await service.deleteReview(tutorId: 't1', reviewId: reviewId);

      final after = await fakeDb
          .collection('tutors').doc('t1').collection('reviews').get();
      expect(after.docs, isEmpty);
    });

    test('recalculates rating after deletion', () async {
      await seedTutor();
      await service.addReview(makeReview(studentId: 's1', rating: 4.0));
      await service.addReview(makeReview(studentId: 's2', rating: 5.0));

      final reviews = await fakeDb
          .collection('tutors').doc('t1').collection('reviews').get();
      final idToDelete = reviews.docs
          .firstWhere((d) => d.data()['studentId'] == 's1')
          .id;

      await service.deleteReview(tutorId: 't1', reviewId: idToDelete);

      final tutor = await fakeDb.collection('tutors').doc('t1').get();
      expect(tutor.data()!['rating'], 5.0);
      expect(tutor.data()!['reviewCount'], 1);
    });

    test('resets rating to 0 when all reviews deleted', () async {
      await seedTutor();
      await service.addReview(makeReview(studentId: 's1', rating: 3.0));
      final reviews = await fakeDb
          .collection('tutors').doc('t1').collection('reviews').get();
      final reviewId = reviews.docs.first.id;

      await service.deleteReview(tutorId: 't1', reviewId: reviewId);

      final tutor = await fakeDb.collection('tutors').doc('t1').get();
      expect(tutor.data()!['rating'], 0.0);
      expect(tutor.data()!['reviewCount'], 0);
    });
  });

  group('ReviewService.hasReviewed', () {
    test('returns true when student already reviewed', () async {
      await seedTutor();
      await service.addReview(makeReview(studentId: 's1'));

      final result =
          await service.hasReviewed(tutorId: 't1', studentId: 's1');
      expect(result, isTrue);
    });

    test('returns false for a different student', () async {
      await seedTutor();
      await service.addReview(makeReview(studentId: 's1'));

      final result =
          await service.hasReviewed(tutorId: 't1', studentId: 's99');
      expect(result, isFalse);
    });
  });
}

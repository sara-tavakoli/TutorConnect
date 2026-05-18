import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _db;

  ReviewService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Adds a review and atomically recalculates the tutor's average rating.
  Future<void> addReview(ReviewModel review) async {
    final batch = _db.batch();

    // Add review document
    final reviewRef = _db
        .collection('tutors')
        .doc(review.tutorId)
        .collection('reviews')
        .doc();
    batch.set(reviewRef, review.toMap());

    // Recalculate average rating
    final existing = await _db
        .collection('tutors')
        .doc(review.tutorId)
        .collection('reviews')
        .get();

    final allRatings = existing.docs
        .map((d) => (d.data()['rating'] as num).toDouble())
        .toList();
    allRatings.add(review.rating);

    final avg = allRatings.reduce((a, b) => a + b) /
        allRatings.length;

    // Update tutor document with new average
    final tutorRef = _db.collection('tutors').doc(review.tutorId);
    batch.update(tutorRef, {
      'rating':      double.parse(avg.toStringAsFixed(1)),
      'reviewCount': allRatings.length,
    });

    await batch.commit();
  }

  /// Returns a real-time stream of reviews for the given tutor.
  Stream<List<ReviewModel>> getReviews(String tutorId) {
    return _db
        .collection('tutors')
        .doc(tutorId)
        .collection('reviews')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ReviewModel.fromMap(d.data(), d.id))
            .toList());
  }

  /// Returns true if [studentId] has already left a review for [tutorId].
  Future<bool> hasReviewed({
    required String tutorId,
    required String studentId,
  }) async {
    final snap = await _db
        .collection('tutors')
        .doc(tutorId)
        .collection('reviews')
        .where('studentId', isEqualTo: studentId)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Deletes a review and recalculates the tutor's average rating and review count.
  Future<void> deleteReview({
    required String tutorId,
    required String reviewId,
  }) async {
    final batch = _db.batch();

    final reviewRef = _db
        .collection('tutors')
        .doc(tutorId)
        .collection('reviews')
        .doc(reviewId);
    batch.delete(reviewRef);

    // Fetch remaining reviews (excluding the one being deleted)
    final remaining = await _db
        .collection('tutors')
        .doc(tutorId)
        .collection('reviews')
        .where(FieldPath.documentId, isNotEqualTo: reviewId)
        .get();

    final tutorRef = _db.collection('tutors').doc(tutorId);
    if (remaining.docs.isEmpty) {
      batch.update(tutorRef, {'rating': 0.0, 'reviewCount': 0});
    } else {
      final ratings = remaining.docs
          .map((d) => (d.data()['rating'] as num).toDouble())
          .toList();
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      batch.update(tutorRef, {
        'rating':      double.parse(avg.toStringAsFixed(1)),
        'reviewCount': ratings.length,
      });
    }

    await batch.commit();
  }
}
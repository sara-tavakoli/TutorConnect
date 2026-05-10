import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a review and update tutor's average rating
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

  // Stream all reviews for a tutor
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

  // Check if student already reviewed this tutor
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

  // Delete a review and recalculate rating
  Future<void> deleteReview({
    required String tutorId,
    required String reviewId,
  }) async {
    await _db
        .collection('tutors')
        .doc(tutorId)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

/// Handles all Firestore operations for bookings — create, read, update status, delete.

class BookingService {
  final FirebaseFirestore _db;

  BookingService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Writes a new booking document and immediately blocks the slot to prevent double-booking.
  Future<void> createBooking(BookingModel booking) async {
    final batch = _db.batch();
    batch.set(_db.collection('bookings').doc(), booking.toMap());
    batch.update(
      _db.collection('tutors').doc(booking.tutorId),
      {'bookedSlots': FieldValue.arrayUnion([booking.slot])},
    );
    await batch.commit();
  }

  /// Real-time stream of all bookings where [studentId] is the student.
  Stream<List<BookingModel>> getBookingsForStudent(String studentId) {
    return _db
        .collection('bookings')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BookingModel.fromMap(d.data(), d.id))
            .toList());
  }

  /// Real-time stream of all bookings where [tutorId] is the tutor.
  Stream<List<BookingModel>> getBookingsForTutor(String tutorId) {
    return _db
        .collection('bookings')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BookingModel.fromMap(d.data(), d.id))
            .toList());
  }

  /// Updates only the status field on a booking (for simple transitions with no slot change).
  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    await _db
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status.name});
  }

  // Confirm a booking and mark the slot as taken (keeps slot visible, blocks re-booking)
  Future<void> confirmBooking(
      String bookingId, String tutorId, String slot) async {
    final batch = _db.batch();
    batch.update(
      _db.collection('bookings').doc(bookingId),
      {'status': BookingStatus.confirmed.name},
    );
    batch.update(
      _db.collection('tutors').doc(tutorId),
      {'bookedSlots': FieldValue.arrayUnion([slot])},
    );
    await batch.commit();
  }

  // Release a slot back to available when a booking is cancelled or completed
  Future<void> releaseSlot(
      String bookingId, String tutorId, String slot, BookingStatus newStatus) async {
    final batch = _db.batch();
    batch.update(
      _db.collection('bookings').doc(bookingId),
      {'status': newStatus.name},
    );
    batch.update(
      _db.collection('tutors').doc(tutorId),
      {'bookedSlots': FieldValue.arrayRemove([slot])},
    );
    await batch.commit();
  }

  /// Permanently deletes a booking document.
  Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }

  /// Returns true if [studentId] has at least one completed session with [tutorId].
  /// Used to gate the "Leave a Review" feature.
  Future<bool> hasCompletedSession(String studentId, String tutorId) async {
    final snap = await _db
        .collection('bookings')
        .where('studentId', isEqualTo: studentId)
        .where('tutorId',   isEqualTo: tutorId)
        .where('status',    isEqualTo: BookingStatus.completed.name)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
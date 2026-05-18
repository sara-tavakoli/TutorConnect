import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

/// Handles all Firestore operations for bookings — create, read, update status, delete.

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new booking
  Future<void> createBooking(BookingModel booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }

  // Stream bookings where user is the student
  Stream<List<BookingModel>> getBookingsForStudent(String studentId) {
    return _db
        .collection('bookings')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BookingModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Stream bookings where user is the tutor
  Stream<List<BookingModel>> getBookingsForTutor(String tutorId) {
    return _db
        .collection('bookings')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BookingModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Update booking status (confirm / cancel / complete)
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

  // Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }

  // True if the student has at least one completed session with a tutor
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
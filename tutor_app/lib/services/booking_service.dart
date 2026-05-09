import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

/// Handles all Firestore operations for bookings — create, read, update status, delete.
/// 
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
        .orderBy('createdAt', descending: true)
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
        .orderBy('createdAt', descending: true)
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

  // Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }
}
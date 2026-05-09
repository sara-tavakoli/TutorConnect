import 'package:flutter/foundation.dart';
import '../../../models/booking_model.dart';
import '../../../models/user_model.dart';
import '../../../services/booking_service.dart';

/// Listens to the bookings stream for the current user and exposes it to the UI.


class BookingProvider extends ChangeNotifier {
  final BookingService _service = BookingService();

  List<BookingModel> _bookings  = [];
  bool               _isLoading = true;
  String?            _error;

  List<BookingModel> get bookings  => _bookings;
  bool               get isLoading => _isLoading;
  String?            get error     => _error;

  // Upcoming = pending or confirmed
  List<BookingModel> get upcoming => _bookings
      .where((b) => b.isPending || b.isConfirmed)
      .toList();

  // Past = cancelled or completed
  List<BookingModel> get past => _bookings
      .where((b) => b.isCancelled || b.isCompleted)
      .toList();

  // Call this once we know the user's uid and role
  void init(String uid, UserRole role) {
    final stream = role == UserRole.tutor
        ? _service.getBookingsForTutor(uid)
        : _service.getBookingsForStudent(uid);

    stream.listen((bookings) {
      _bookings  = bookings;
      _isLoading = false;
      _error     = null;
      notifyListeners();
    }, onError: (e) {
      _error     = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createBooking(BookingModel booking) async {
    await _service.createBooking(booking);
  }

  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    await _service.updateStatus(bookingId, status);
  }

  Future<void> deleteBooking(String bookingId) async {
    await _service.deleteBooking(bookingId);
  }
  
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/models/booking_model.dart';

void main() {
  final createdAt = DateTime(2024, 6, 1);

  Map<String, dynamic> bookingMap({String status = 'pending', String? note}) => {
    'studentId': 's1',
    'studentName': 'Jane Student',
    'tutorId': 't1',
    'tutorName': 'John Tutor',
    'subject': 'Math',
    'slot': 'Mon 2pm',
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    'note': note,
  };

  group('BookingModel.fromMap', () {
    test('parses all required fields', () {
      final b = BookingModel.fromMap(bookingMap(), 'b1');
      expect(b.id, 'b1');
      expect(b.studentId, 's1');
      expect(b.tutorId, 't1');
      expect(b.subject, 'Math');
      expect(b.slot, 'Mon 2pm');
      expect(b.status, BookingStatus.pending);
      expect(b.createdAt, createdAt);
      expect(b.note, isNull);
    });

    test('parses optional note', () {
      final b = BookingModel.fromMap(bookingMap(note: 'Need help with integration'), 'b2');
      expect(b.note, 'Need help with integration');
    });

    test('parses all status values', () {
      for (final s in BookingStatus.values) {
        final b = BookingModel.fromMap(bookingMap(status: s.name), 'b');
        expect(b.status, s);
      }
    });

    test('defaults unknown status to pending', () {
      final b = BookingModel.fromMap(bookingMap(status: 'unknown'), 'b');
      expect(b.status, BookingStatus.pending);
    });
  });

  group('BookingModel status getters', () {
    test('isPending is true only for pending', () {
      final b = BookingModel.fromMap(bookingMap(status: 'pending'), 'b');
      expect(b.isPending, isTrue);
      expect(b.isConfirmed, isFalse);
      expect(b.isCancelled, isFalse);
      expect(b.isCompleted, isFalse);
    });

    test('isConfirmed is true only for confirmed', () {
      final b = BookingModel.fromMap(bookingMap(status: 'confirmed'), 'b');
      expect(b.isConfirmed, isTrue);
      expect(b.isPending, isFalse);
    });

    test('isCancelled is true only for cancelled', () {
      final b = BookingModel.fromMap(bookingMap(status: 'cancelled'), 'b');
      expect(b.isCancelled, isTrue);
    });

    test('isCompleted is true only for completed', () {
      final b = BookingModel.fromMap(bookingMap(status: 'completed'), 'b');
      expect(b.isCompleted, isTrue);
    });
  });

  group('BookingModel.toMap', () {
    test('serialises status as string', () {
      final b = BookingModel.fromMap(bookingMap(status: 'confirmed'), 'b1');
      expect(b.toMap()['status'], 'confirmed');
    });

    test('round-trips through fromMap', () {
      final original = BookingModel.fromMap(bookingMap(note: 'test'), 'b1');
      final restored = BookingModel.fromMap(original.toMap(), 'b1');
      expect(restored.subject, original.subject);
      expect(restored.status, original.status);
      expect(restored.note, original.note);
    });
  });

  group('BookingModel.copyWith', () {
    test('updates status only', () {
      final b = BookingModel.fromMap(bookingMap(), 'b1');
      final confirmed = b.copyWith(status: BookingStatus.confirmed);
      expect(confirmed.status, BookingStatus.confirmed);
      expect(confirmed.subject, b.subject);
      expect(confirmed.slot, b.slot);
    });
  });
}

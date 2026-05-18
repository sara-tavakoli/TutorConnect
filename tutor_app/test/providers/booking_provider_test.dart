import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/features/bookings/providers/booking_provider.dart';
import 'package:tutorconnect/models/booking_model.dart';
import 'package:tutorconnect/models/user_model.dart';
import 'package:tutorconnect/services/booking_service.dart';

void main() {
  late FakeFirebaseFirestore fakeDb;
  late BookingService bookingService;

  final baseDate = DateTime(2024, 6, 1);

  Map<String, dynamic> bookingDoc({
    String studentId = 's1',
    String tutorId = 't1',
    String status = 'pending',
    String slot = 'Mon 2pm',
  }) =>
      {
        'studentId': studentId,
        'studentName': 'Jane',
        'tutorId': tutorId,
        'tutorName': 'John',
        'subject': 'Math',
        'slot': slot,
        'status': status,
        'createdAt': Timestamp.fromDate(baseDate),
        'note': null,
      };

  setUp(() {
    fakeDb = FakeFirebaseFirestore();
    bookingService = BookingService(db: fakeDb);
  });

  Future<BookingProvider> buildProvider(String uid, UserRole role) async {
    final provider = BookingProvider(service: bookingService);
    provider.init(uid, role);
    await Future.delayed(Duration.zero);
    return provider;
  }

  group('BookingProvider — upcoming / past split', () {
    test('upcoming contains pending and confirmed bookings', () async {
      await fakeDb.collection('bookings').add(bookingDoc(status: 'pending'));
      await fakeDb.collection('bookings').add(bookingDoc(status: 'confirmed'));
      await fakeDb.collection('bookings').add(bookingDoc(status: 'cancelled'));

      final provider = await buildProvider('s1', UserRole.student);

      expect(provider.upcoming.length, 2);
      expect(
          provider.upcoming.map((b) => b.status),
          containsAll(
              [BookingStatus.pending, BookingStatus.confirmed]));
    });

    test('past contains cancelled and completed bookings', () async {
      await fakeDb.collection('bookings').add(bookingDoc(status: 'cancelled'));
      await fakeDb.collection('bookings').add(bookingDoc(status: 'completed'));

      final provider = await buildProvider('s1', UserRole.student);

      expect(provider.past.length, 2);
    });

    test('empty upcoming and past when no bookings', () async {
      final provider = await buildProvider('s1', UserRole.student);
      expect(provider.upcoming, isEmpty);
      expect(provider.past, isEmpty);
    });
  });

  group('BookingProvider — role-based streaming', () {
    test('student sees only their own bookings', () async {
      await fakeDb
          .collection('bookings')
          .add(bookingDoc(studentId: 's1', tutorId: 't1'));
      await fakeDb
          .collection('bookings')
          .add(bookingDoc(studentId: 's2', tutorId: 't1'));

      final provider = await buildProvider('s1', UserRole.student);
      expect(provider.bookings.length, 1);
      expect(provider.bookings.first.studentId, 's1');
    });

    test('tutor sees only their sessions', () async {
      await fakeDb
          .collection('bookings')
          .add(bookingDoc(tutorId: 't1'));
      await fakeDb
          .collection('bookings')
          .add(bookingDoc(tutorId: 't2'));

      final provider = await buildProvider('t1', UserRole.tutor);
      expect(provider.bookings.length, 1);
      expect(provider.bookings.first.tutorId, 't1');
    });
  });

  group('BookingProvider — updateStatus', () {
    test('changing status is reflected in the stream', () async {
      final docRef = await fakeDb
          .collection('bookings')
          .add(bookingDoc(status: 'pending'));

      final provider = await buildProvider('s1', UserRole.student);
      expect(provider.upcoming.first.status, BookingStatus.pending);

      await provider.updateStatus(docRef.id, BookingStatus.cancelled);
      await Future.delayed(Duration.zero);

      expect(provider.upcoming, isEmpty);
      expect(provider.past.first.status, BookingStatus.cancelled);
    });
  });

  group('BookingProvider — createBooking', () {
    test('new booking appears in upcoming', () async {
      final provider = await buildProvider('s1', UserRole.student);
      expect(provider.bookings, isEmpty);

      await provider.createBooking(BookingModel(
        id: '',
        studentId: 's1',
        studentName: 'Jane',
        tutorId: 't1',
        tutorName: 'John',
        subject: 'Math',
        slot: 'Mon 2pm',
        status: BookingStatus.pending,
        createdAt: baseDate,
      ));
      await Future.delayed(Duration.zero);

      expect(provider.upcoming.length, 1);
    });
  });
}

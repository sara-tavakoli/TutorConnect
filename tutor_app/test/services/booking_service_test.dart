import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/models/booking_model.dart';
import 'package:tutorconnect/services/booking_service.dart';

void main() {
  late FakeFirebaseFirestore fakeDb;
  late BookingService service;

  final baseDate = DateTime(2024, 6, 1);

  BookingModel makeBooking({
    String id = 'b1',
    String studentId = 's1',
    String tutorId = 't1',
    String slot = 'Mon 2pm',
    BookingStatus status = BookingStatus.pending,
  }) =>
      BookingModel(
        id: id,
        studentId: studentId,
        studentName: 'Jane',
        tutorId: tutorId,
        tutorName: 'John',
        subject: 'Math',
        slot: slot,
        status: status,
        createdAt: baseDate,
      );

  setUp(() {
    fakeDb = FakeFirebaseFirestore();
    service = BookingService(db: fakeDb);
  });

  group('BookingService.createBooking', () {
    test('adds a document to the bookings collection', () async {
      await service.createBooking(makeBooking());

      final snap = await fakeDb.collection('bookings').get();
      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['subject'], 'Math');
    });
  });

  group('BookingService.getBookingsForStudent', () {
    test('returns only the given student\'s bookings', () async {
      await service.createBooking(makeBooking(studentId: 's1'));
      await service.createBooking(makeBooking(studentId: 's2'));

      final bookings = await service.getBookingsForStudent('s1').first;
      expect(bookings.length, 1);
      expect(bookings.first.studentId, 's1');
    });
  });

  group('BookingService.getBookingsForTutor', () {
    test('returns only the given tutor\'s bookings', () async {
      await service.createBooking(makeBooking(tutorId: 't1'));
      await service.createBooking(makeBooking(tutorId: 't2'));

      final bookings = await service.getBookingsForTutor('t1').first;
      expect(bookings.length, 1);
      expect(bookings.first.tutorId, 't1');
    });
  });

  group('BookingService.updateStatus', () {
    test('changes status field in Firestore', () async {
      final docRef = await fakeDb.collection('bookings').add(makeBooking().toMap());

      await service.updateStatus(docRef.id, BookingStatus.confirmed);

      final doc = await fakeDb.collection('bookings').doc(docRef.id).get();
      expect(doc.data()!['status'], 'confirmed');
    });
  });

  group('BookingService.confirmBooking', () {
    test('sets booking status to confirmed', () async {
      final docRef =
          await fakeDb.collection('bookings').add(makeBooking().toMap());
      await fakeDb
          .collection('tutors')
          .doc('t1')
          .set({'availability': ['Mon 2pm', 'Tue 3pm'], 'bookedSlots': []});

      await service.confirmBooking(docRef.id, 't1', 'Mon 2pm');

      final booking =
          await fakeDb.collection('bookings').doc(docRef.id).get();
      expect(booking.data()!['status'], 'confirmed');
    });

    test('adds slot to tutor\'s bookedSlots', () async {
      final docRef =
          await fakeDb.collection('bookings').add(makeBooking().toMap());
      await fakeDb
          .collection('tutors')
          .doc('t1')
          .set({'availability': ['Mon 2pm'], 'bookedSlots': []});

      await service.confirmBooking(docRef.id, 't1', 'Mon 2pm');

      final tutor = await fakeDb.collection('tutors').doc('t1').get();
      expect(tutor.data()!['bookedSlots'], contains('Mon 2pm'));
      expect(tutor.data()!['availability'], contains('Mon 2pm'));
    });
  });

  group('BookingService.releaseSlot', () {
    test('sets booking to new status and removes slot from bookedSlots', () async {
      final docRef =
          await fakeDb.collection('bookings').add(makeBooking().toMap());
      await fakeDb
          .collection('tutors')
          .doc('t1')
          .set({'availability': ['Mon 2pm'], 'bookedSlots': ['Mon 2pm']});

      await service.releaseSlot(docRef.id, 't1', 'Mon 2pm', BookingStatus.cancelled);

      final booking =
          await fakeDb.collection('bookings').doc(docRef.id).get();
      expect(booking.data()!['status'], 'cancelled');

      final tutor = await fakeDb.collection('tutors').doc('t1').get();
      expect(tutor.data()!['bookedSlots'], isNot(contains('Mon 2pm')));
    });
  });

  group('BookingService.hasCompletedSession', () {
    test('returns true when completed booking exists', () async {
      await service
          .createBooking(makeBooking(status: BookingStatus.completed));

      final result = await service.hasCompletedSession('s1', 't1');
      expect(result, isTrue);
    });

    test('returns false when no completed booking exists', () async {
      await service.createBooking(makeBooking(status: BookingStatus.pending));

      final result = await service.hasCompletedSession('s1', 't1');
      expect(result, isFalse);
    });

    test('returns false for different student-tutor pair', () async {
      await service
          .createBooking(makeBooking(status: BookingStatus.completed));

      final result = await service.hasCompletedSession('s1', 't99');
      expect(result, isFalse);
    });
  });

  group('BookingService.deleteBooking', () {
    test('removes the document', () async {
      final docRef =
          await fakeDb.collection('bookings').add(makeBooking().toMap());
      await service.deleteBooking(docRef.id);

      final doc = await fakeDb.collection('bookings').doc(docRef.id).get();
      expect(doc.exists, isFalse);
    });
  });
}

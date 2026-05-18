import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/features/bookings/widgets/booking_card.dart';
import 'package:tutorconnect/models/booking_model.dart';

void main() {
  final baseDate = DateTime(2024, 6, 1);

  BookingModel makeBooking({
    BookingStatus status = BookingStatus.pending,
    String? note,
  }) =>
      BookingModel(
        id: 'b1',
        studentId: 's1',
        studentName: 'Jane Student',
        tutorId: 't1',
        tutorName: 'John Tutor',
        subject: 'Math',
        slot: 'Mon 2pm',
        status: status,
        createdAt: baseDate,
        note: note,
      );

  Widget build(BookingModel booking,
      {bool isTutor = false,
      VoidCallback? onConfirm,
      VoidCallback? onComplete,
      VoidCallback? onCancel}) =>
      MaterialApp(
        home: Scaffold(
          body: BookingCard(
            booking: booking,
            isTutor: isTutor,
            onConfirm: onConfirm,
            onComplete: onComplete,
            onCancel: onCancel,
          ),
        ),
      );

  group('BookingCard — booking details', () {
    testWidgets('shows subject and slot', (tester) async {
      await tester.pumpWidget(build(makeBooking()));
      expect(find.text('Math'), findsOneWidget);
      expect(find.text('Mon 2pm'), findsOneWidget);
    });

    testWidgets('shows tutor name for student view', (tester) async {
      await tester.pumpWidget(
          build(makeBooking(), isTutor: false));
      expect(find.text('John Tutor'), findsOneWidget);
    });

    testWidgets('shows student name for tutor view', (tester) async {
      await tester.pumpWidget(
          build(makeBooking(), isTutor: true));
      expect(find.text('Jane Student'), findsOneWidget);
    });

    testWidgets('shows status badge text', (tester) async {
      await tester.pumpWidget(build(makeBooking(status: BookingStatus.confirmed)));
      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('shows note when provided', (tester) async {
      await tester.pumpWidget(
          build(makeBooking(note: 'Need help with integration')));
      expect(find.text('Need help with integration'), findsOneWidget);
    });

    testWidgets('does not show note section when note is null', (tester) async {
      await tester.pumpWidget(build(makeBooking()));
      expect(find.text('Need help'), findsNothing);
    });
  });

  group('BookingCard — tutor actions (pending booking)', () {
    testWidgets('shows Confirm button for tutor with pending booking',
        (tester) async {
      await tester.pumpWidget(build(
        makeBooking(status: BookingStatus.pending),
        isTutor: true,
        onConfirm: () {},
        onCancel: () {},
      ));
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('shows Cancel button for tutor with pending booking',
        (tester) async {
      await tester.pumpWidget(build(
        makeBooking(status: BookingStatus.pending),
        isTutor: true,
        onConfirm: () {},
        onCancel: () {},
      ));
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows Mark Done for tutor with confirmed booking',
        (tester) async {
      await tester.pumpWidget(build(
        makeBooking(status: BookingStatus.confirmed),
        isTutor: true,
        onComplete: () {},
        onCancel: () {},
      ));
      expect(find.text('Mark Done'), findsOneWidget);
    });

    testWidgets('does not show Confirm for student view', (tester) async {
      await tester.pumpWidget(build(
        makeBooking(status: BookingStatus.pending),
        isTutor: false,
        onCancel: () {},
      ));
      expect(find.text('Confirm'), findsNothing);
    });
  });

  group('BookingCard — student actions', () {
    testWidgets('shows Cancel button for student with pending booking',
        (tester) async {
      await tester.pumpWidget(build(
        makeBooking(status: BookingStatus.pending),
        isTutor: false,
        onCancel: () {},
      ));
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('no actions shown for completed booking', (tester) async {
      await tester.pumpWidget(build(
        makeBooking(status: BookingStatus.completed),
        isTutor: false,
        onCancel: () {},
      ));
      expect(find.text('Cancel'), findsNothing);
    });
  });

  group('BookingCard — action callbacks', () {
    testWidgets('confirm callback fires when Confirm is tapped',
        (tester) async {
      var confirmed = false;
      await tester.pumpWidget(build(
        makeBooking(status: BookingStatus.pending),
        isTutor: true,
        onConfirm: () => confirmed = true,
        onCancel: () {},
      ));
      await tester.tap(find.text('Confirm'));
      expect(confirmed, isTrue);
    });

    testWidgets('cancel callback fires when Cancel is tapped', (tester) async {
      var cancelled = false;
      await tester.pumpWidget(build(
        makeBooking(status: BookingStatus.pending),
        isTutor: false,
        onCancel: () => cancelled = true,
      ));
      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });
  });
}

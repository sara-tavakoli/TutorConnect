import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tutorconnect/features/auth/providers/auth_provider.dart';
import 'package:tutorconnect/features/bookings/providers/booking_provider.dart';
import 'package:tutorconnect/features/bookings/screens/bookings_screen.dart';
import 'package:tutorconnect/models/booking_model.dart';
import 'package:tutorconnect/models/user_model.dart';
import 'package:tutorconnect/services/auth_service.dart';
import 'package:tutorconnect/services/booking_service.dart';

// Pre-authenticated provider stub
class _FakeAuthProvider extends AuthProvider {
  final UserModel _fakeUser;
  _FakeAuthProvider(this._fakeUser)
      : super(
          service: AuthService(
            auth: MockFirebaseAuth(),
            db: FakeFirebaseFirestore(),
          ),
        );

  @override
  UserModel? get user => _fakeUser;

  @override
  AuthStatus get status => AuthStatus.authenticated;

  @override
  bool get isAuth => true;
}

final _studentUser = UserModel(
  uid: 'student1',
  name: 'Jane Smith',
  email: 'jane@example.com',
  role: UserRole.student,
  createdAt: DateTime(2024),
);

final _tutorUser = UserModel(
  uid: 'tutor1',
  name: 'Bob Tutor',
  email: 'bob@example.com',
  role: UserRole.tutor,
  createdAt: DateTime(2024),
);

BookingModel _booking({
  String id = 'b1',
  BookingStatus status = BookingStatus.pending,
}) =>
    BookingModel(
      id: id,
      studentId: 'student1',
      studentName: 'Jane Smith',
      tutorId: 'tutor1',
      tutorName: 'Bob Tutor',
      subject: 'Maths',
      slot: 'Mon 9am',
      status: status,
      createdAt: DateTime(2024),
    );

// Creates a pre-seeded BookingProvider. Does NOT use Future.delayed
// because that hangs in testWidgets FakeAsync before pump() is called.
Future<BookingProvider> makeProvider(
    List<BookingModel> bookings, UserModel user) async {
  final db = FakeFirebaseFirestore();
  final service = BookingService(db: db);
  for (final b in bookings) {
    await db.collection('bookings').doc(b.id).set(b.toMap());
  }
  final provider = BookingProvider(service: service);
  provider.init(user.uid, user.role);
  return provider;
}

Widget buildScreen(UserModel authUser, BookingProvider bookingProvider) =>
    ChangeNotifierProvider<AuthProvider>.value(
      value: _FakeAuthProvider(authUser),
      child: MaterialApp(
        home: BookingsScreen(testProvider: bookingProvider),
      ),
    );

void main() {
  group('BookingsScreen — rendering', () {
    testWidgets('shows My Bookings title for student', (tester) async {
      final provider = await makeProvider([_booking()], _studentUser);
      await tester.pumpWidget(buildScreen(_studentUser, provider));
      await tester.pump(); // stream emits
      await tester.pump(); // rebuild
      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('shows Session Requests title for tutor', (tester) async {
      final provider = await makeProvider([_booking()], _tutorUser);
      await tester.pumpWidget(buildScreen(_tutorUser, provider));
      await tester.pump();
      await tester.pump();
      expect(find.text('Session Requests'), findsOneWidget);
    });

    testWidgets('shows Upcoming and Past tabs', (tester) async {
      final provider = await makeProvider([], _studentUser);
      await tester.pumpWidget(buildScreen(_studentUser, provider));
      await tester.pump();
      await tester.pump();
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
    });

    testWidgets('pending booking subject appears in Upcoming tab', (tester) async {
      final provider = await makeProvider(
          [_booking(status: BookingStatus.pending)], _studentUser);
      await tester.pumpWidget(buildScreen(_studentUser, provider));
      await tester.pump();
      await tester.pump();
      expect(find.text('Maths'), findsOneWidget);
    });
  });

  group('BookingsScreen — tab navigation', () {
    testWidgets('tapping Past tab shows completed booking', (tester) async {
      final completed = _booking(id: 'b2', status: BookingStatus.completed);
      final provider = await makeProvider([completed], _studentUser);
      await tester.pumpWidget(buildScreen(_studentUser, provider));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Past'));
      await tester.pumpAndSettle();

      expect(find.text('Maths'), findsOneWidget);
    });

    testWidgets('Upcoming tab is empty when all bookings are completed',
        (tester) async {
      final completed = _booking(id: 'b1', status: BookingStatus.completed);
      final provider = await makeProvider([completed], _studentUser);
      await tester.pumpWidget(buildScreen(_studentUser, provider));
      await tester.pump();
      await tester.pump();

      // Upcoming tab is selected by default — completed booking should not appear
      expect(find.text('Maths'), findsNothing);
    });
  });
}

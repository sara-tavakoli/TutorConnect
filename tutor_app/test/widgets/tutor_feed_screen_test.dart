import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tutorconnect/features/auth/providers/auth_provider.dart';
import 'package:tutorconnect/features/tutors/providers/tutor_provider.dart';
import 'package:tutorconnect/features/tutors/screens/tutor_feed_screen.dart';
import 'package:tutorconnect/models/tutor_model.dart';
import 'package:tutorconnect/services/auth_service.dart';
import 'package:tutorconnect/services/tutor_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

Future<void> useTallCanvas(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// Seeds [db] with two tutors and returns a provider backed by that db.
// Does NOT use Future.delayed — that hangs inside testWidgets FakeAsync before pump().
Future<TutorProvider> makeProvider(FakeFirebaseFirestore db) async {
  final tutors = [
    const TutorModel(
      uid: 't1', name: 'Alice Brown', bio: 'Maths expert',
      subjects: ['Maths', 'Physics'], hourlyRate: 40,
      availability: ['Mon 9am'], rating: 4.8, reviewCount: 10,
    ),
    const TutorModel(
      uid: 't2', name: 'Bob Green', bio: 'English tutor',
      subjects: ['English'], hourlyRate: 30,
      availability: ['Tue 10am'], rating: 4.2, reviewCount: 5,
    ),
  ];
  for (final t in tutors) {
    await db.collection('tutors').doc(t.uid).set(t.toMap());
  }
  return TutorProvider(service: TutorService(db: db));
}

Widget buildScreen(TutorProvider provider) {
  final auth = AuthProvider(
    service: AuthService(auth: MockFirebaseAuth(), db: FakeFirebaseFirestore()),
  );
  return ChangeNotifierProvider<AuthProvider>.value(
    value: auth,
    child: MaterialApp(home: TutorFeedScreen(testProvider: provider)),
  );
}

void main() {
  group('TutorFeedScreen — rendering', () {
    testWidgets('shows Find a Tutor heading', (tester) async {
      await useTallCanvas(tester);
      final provider = await makeProvider(FakeFirebaseFirestore());
      await tester.pumpWidget(buildScreen(provider));
      await tester.pump(); // process stream + first rebuild
      expect(find.text('Find a Tutor'), findsOneWidget);
    });

    testWidgets('shows search bar hint text', (tester) async {
      await useTallCanvas(tester);
      final provider = await makeProvider(FakeFirebaseFirestore());
      await tester.pumpWidget(buildScreen(provider));
      await tester.pump();
      expect(find.text('Search by name or subject…'), findsOneWidget);
    });

    testWidgets('shows Map view button', (tester) async {
      await useTallCanvas(tester);
      final provider = await makeProvider(FakeFirebaseFirestore());
      await tester.pumpWidget(buildScreen(provider));
      await tester.pump();
      expect(find.text('Map view'), findsOneWidget);
    });

    testWidgets('shows tutor names once stream loads', (tester) async {
      await useTallCanvas(tester);
      final provider = await makeProvider(FakeFirebaseFirestore());
      await tester.pumpWidget(buildScreen(provider));
      await tester.pump(); // stream emits → isLoading=false
      await tester.pump(); // rebuild with tutor list
      expect(find.text('Alice Brown'), findsOneWidget);
      expect(find.text('Bob Green'), findsOneWidget);
    });

    testWidgets('shows map discovery banner once loaded', (tester) async {
      await useTallCanvas(tester);
      final provider = await makeProvider(FakeFirebaseFirestore());
      await tester.pumpWidget(buildScreen(provider));
      await tester.pump();
      await tester.pump();
      expect(find.text('Explore tutors near you on the map'), findsOneWidget);
    });
  });

  group('TutorFeedScreen — search interaction', () {
    testWidgets('typing in search bar narrows tutor list', (tester) async {
      await useTallCanvas(tester);
      final provider = await makeProvider(FakeFirebaseFirestore());
      await tester.pumpWidget(buildScreen(provider));
      await tester.pump();
      await tester.pump(); // ensure tutors are visible

      await tester.enterText(find.byType(TextField), 'Alice');
      await tester.pump();

      expect(find.text('Alice Brown'), findsOneWidget);
      expect(find.text('Bob Green'), findsNothing);
    });

    testWidgets('search with no match shows empty state', (tester) async {
      await useTallCanvas(tester);
      final provider = await makeProvider(FakeFirebaseFirestore());
      await tester.pumpWidget(buildScreen(provider));
      await tester.pump();
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'zzznomatch');
      await tester.pump();

      expect(find.text('No tutors found'), findsOneWidget);
    });
  });
}

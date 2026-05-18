import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/features/tutors/providers/tutor_provider.dart';
import 'package:tutorconnect/services/tutor_service.dart';

void main() {
  late FakeFirebaseFirestore fakeDb;
  late TutorService service;

  // Three tutors: Alice (Math+Physics, \$40, 4.5★×10), Bob (English, \$30, 3.5★×5),
  // Charlie (Math, \$50, 5.0★×20)
  final tutors = [
    {
      'name': 'Alice',
      'bio': '',
      'subjects': ['Math', 'Physics'],
      'hourlyRate': 40.0,
      'availability': ['Mon 2pm'],
      'bookedSlots': <String>[],
      'rating': 4.5,
      'reviewCount': 10,
      'photoUrl': null,
      'university': null,
      'year': null,
      'latitude': null,
      'longitude': null,
    },
    {
      'name': 'Bob',
      'bio': '',
      'subjects': ['English'],
      'hourlyRate': 30.0,
      'availability': ['Tue 3pm'],
      'bookedSlots': <String>[],
      'rating': 3.5,
      'reviewCount': 5,
      'photoUrl': null,
      'university': null,
      'year': null,
      'latitude': null,
      'longitude': null,
    },
    {
      'name': 'Charlie',
      'bio': '',
      'subjects': ['Math'],
      'hourlyRate': 50.0,
      'availability': <String>[],
      'bookedSlots': <String>[],
      'rating': 5.0,
      'reviewCount': 20,
      'photoUrl': null,
      'university': null,
      'year': null,
      'latitude': null,
      'longitude': null,
    },
  ];

  setUp(() async {
    fakeDb = FakeFirebaseFirestore();
    for (var i = 0; i < tutors.length; i++) {
      await fakeDb.collection('tutors').doc('t${i + 1}').set(tutors[i]);
    }
    service = TutorService(db: fakeDb);
  });

  Future<TutorProvider> buildProvider() async {
    final provider = TutorProvider(service: service);
    // Wait for the stream to emit the initial snapshot
    await Future.delayed(Duration.zero);
    return provider;
  }

  group('TutorProvider — loading state', () {
    test('starts in loading state', () {
      final provider = TutorProvider(service: service);
      expect(provider.isLoading, isTrue);
    });

    test('clears loading after data arrives', () async {
      final provider = await buildProvider();
      expect(provider.isLoading, isFalse);
    });
  });

  group('TutorProvider — filteredTutors (no filters)', () {
    test('returns all tutors when no filter is applied', () async {
      final provider = await buildProvider();
      expect(provider.filteredTutors.length, 3);
    });
  });

  group('TutorProvider — subject filter', () {
    test('filters tutors by subject', () async {
      final provider = await buildProvider();
      provider.setSubjectFilter('Math');
      expect(provider.filteredTutors.length, 2);
      expect(provider.filteredTutors.map((t) => t.name),
          containsAll(['Alice', 'Charlie']));
    });

    test('returns all tutors when filter is "All"', () async {
      final provider = await buildProvider();
      provider.setSubjectFilter('Math');
      provider.setSubjectFilter('All');
      expect(provider.filteredTutors.length, 3);
    });
  });

  group('TutorProvider — search query', () {
    test('filters by tutor name (case-insensitive)', () async {
      final provider = await buildProvider();
      provider.setSearchQuery('alice');
      expect(provider.filteredTutors.length, 1);
      expect(provider.filteredTutors.first.name, 'Alice');
    });

    test('filters by subject name', () async {
      final provider = await buildProvider();
      provider.setSearchQuery('english');
      expect(provider.filteredTutors.length, 1);
      expect(provider.filteredTutors.first.name, 'Bob');
    });

    test('returns empty list for no matches', () async {
      final provider = await buildProvider();
      provider.setSearchQuery('zzznomatch');
      expect(provider.filteredTutors, isEmpty);
    });
  });

  group('TutorProvider — sorting', () {
    test('sorts by rating descending', () async {
      final provider = await buildProvider();
      provider.setSort(TutorSort.ratingDesc);
      final names = provider.filteredTutors.map((t) => t.name).toList();
      expect(names.first, 'Charlie'); // 5.0
      expect(names.last, 'Bob');      // 3.5
    });

    test('sorts by price low to high', () async {
      final provider = await buildProvider();
      provider.setSort(TutorSort.priceLow);
      final rates =
          provider.filteredTutors.map((t) => t.hourlyRate).toList();
      expect(rates, equals([30.0, 40.0, 50.0]));
    });

    test('sorts by price high to low', () async {
      final provider = await buildProvider();
      provider.setSort(TutorSort.priceHigh);
      final rates =
          provider.filteredTutors.map((t) => t.hourlyRate).toList();
      expect(rates, equals([50.0, 40.0, 30.0]));
    });

    test('recommended sort ranks by rating × reviewCount', () async {
      final provider = await buildProvider();
      provider.setSort(TutorSort.recommended);
      // Charlie: 5.0×20=100, Alice: 4.5×10=45, Bob: 3.5×5=17.5
      expect(provider.filteredTutors.first.name, 'Charlie');
      expect(provider.filteredTutors.last.name, 'Bob');
    });
  });

  group('TutorProvider — clearFilters', () {
    test('resets subject, search and sort', () async {
      final provider = await buildProvider();
      provider.setSubjectFilter('Math');
      provider.setSearchQuery('Alice');
      provider.setSort(TutorSort.priceLow);

      provider.clearFilters();

      expect(provider.selectedSubject, 'All');
      expect(provider.searchQuery, '');
      expect(provider.sort, TutorSort.recommended);
      expect(provider.filteredTutors.length, 3);
    });
  });

  group('TutorProvider — allSubjects', () {
    test('always includes "All" as first entry', () async {
      final provider = await buildProvider();
      expect(provider.allSubjects.first, 'All');
    });

    test('includes all unique subjects from tutors', () async {
      final provider = await buildProvider();
      expect(provider.allSubjects,
          containsAll(['All', 'Math', 'Physics', 'English']));
    });
  });
}

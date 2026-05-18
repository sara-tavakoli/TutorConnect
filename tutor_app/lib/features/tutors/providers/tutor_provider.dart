import 'package:flutter/foundation.dart';
import '../../../models/tutor_model.dart';
import '../../../services/tutor_service.dart';

enum TutorSort { recommended, ratingDesc, priceLow, priceHigh }

extension TutorSortLabel on TutorSort {
  String get label {
    switch (this) {
      case TutorSort.recommended: return 'Recommended';
      case TutorSort.ratingDesc:  return 'Top Rated';
      case TutorSort.priceLow:    return 'Price: Low';
      case TutorSort.priceHigh:   return 'Price: High';
    }
  }
}

class TutorProvider extends ChangeNotifier {
  late final TutorService _service;

  List<TutorModel> _allTutors       = [];
  String           _searchQuery     = '';
  String           _selectedSubject = 'All';
  TutorSort        _sort            = TutorSort.recommended;
  bool             _isLoading       = true;

  List<TutorModel> get allTutors       => _allTutors;
  String           get searchQuery     => _searchQuery;
  String           get selectedSubject => _selectedSubject;
  TutorSort        get sort            => _sort;
  bool             get isLoading       => _isLoading;

  List<TutorModel> get filteredTutors {
    final filtered = _allTutors.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.subjects.any((s) =>
              s.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesSubject = _selectedSubject == 'All' ||
          t.subjects.contains(_selectedSubject);
      return matchesSearch && matchesSubject;
    }).toList();

    switch (_sort) {
      case TutorSort.ratingDesc:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
      case TutorSort.priceLow:
        filtered.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
      case TutorSort.priceHigh:
        filtered.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
      case TutorSort.recommended:
        filtered.sort((a, b) {
          final score = (b.rating * b.reviewCount)
              .compareTo(a.rating * a.reviewCount);
          return score;
        });
    }
    return filtered;
  }

  List<String> get allSubjects {
    final subjects = <String>{'All'};
    for (final t in _allTutors) {
      subjects.addAll(t.subjects);
    }
    return subjects.toList();
  }

  TutorProvider({TutorService? service}) {
    _service = service ?? TutorService();
    _listenToTutors();
  }

  void _listenToTutors() {
    _service.getTutors().listen((tutors) {
      _allTutors = tutors;
      _isLoading = false;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSubjectFilter(String subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setSort(TutorSort sort) {
    _sort = sort;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery     = '';
    _selectedSubject = 'All';
    _sort            = TutorSort.recommended;
    notifyListeners();
  }
}

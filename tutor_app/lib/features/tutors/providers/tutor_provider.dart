import 'package:flutter/foundation.dart';
import '../../../models/tutor_model.dart';
import '../../../services/tutor_service.dart';

class TutorProvider extends ChangeNotifier {
  final TutorService _service = TutorService();

  List<TutorModel> _allTutors    = [];
  String           _searchQuery  = '';
  String           _selectedSubject = 'All';
  bool             _isLoading    = true;

  List<TutorModel> get allTutors       => _allTutors;
  String           get searchQuery     => _searchQuery;
  String           get selectedSubject => _selectedSubject;
  bool             get isLoading       => _isLoading;

  // Filtered list based on search + subject
  List<TutorModel> get filteredTutors {
    return _allTutors.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.subjects.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesSubject = _selectedSubject == 'All' ||
          t.subjects.contains(_selectedSubject);
      return matchesSearch && matchesSubject;
    }).toList();
  }

  // All unique subjects across all tutors
  List<String> get allSubjects {
    final subjects = <String>{'All'};
    for (final t in _allTutors) {
      subjects.addAll(t.subjects);
    }
    return subjects.toList();
  }

  TutorProvider() {
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

  void clearFilters() {
    _searchQuery     = '';
    _selectedSubject = 'All';
    notifyListeners();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tutor_model.dart';

/// Handles all Firestore read/write operations for tutor profiles.
class TutorService {
  final FirebaseFirestore _db;

  TutorService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Returns a real-time stream of all tutor documents.
  Stream<List<TutorModel>> getTutors() {
    return _db.collection('tutors').snapshots().map((snap) =>
        snap.docs.map((d) => TutorModel.fromMap(d.data(), d.id)).toList());
  }

  /// Fetches a single tutor by [uid]. Returns null if the document doesn't exist.
  Future<TutorModel?> getTutorById(String uid) async {
    final doc = await _db.collection('tutors').doc(uid).get();
    if (!doc.exists) return null;
    return TutorModel.fromMap(doc.data()!, doc.id);
  }

  /// Overwrites the tutor document with the values from [tutor].
  Future<void> updateTutor(TutorModel tutor) async {
    await _db.collection('tutors').doc(tutor.uid).update(tutor.toMap());
  }

  /// Permanently deletes the tutor document for [uid].
  Future<void> deleteTutor(String uid) async {
    await _db.collection('tutors').doc(uid).delete();
  }
}

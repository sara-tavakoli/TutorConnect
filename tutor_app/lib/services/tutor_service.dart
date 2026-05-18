import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tutor_model.dart';

class TutorService {
  final FirebaseFirestore _db;

  TutorService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<TutorModel>> getTutors() {
    return _db.collection('tutors').snapshots().map((snap) =>
        snap.docs.map((d) => TutorModel.fromMap(d.data(), d.id)).toList());
  }

  Future<TutorModel?> getTutorById(String uid) async {
    final doc = await _db.collection('tutors').doc(uid).get();
    if (!doc.exists) return null;
    return TutorModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateTutor(TutorModel tutor) async {
    await _db.collection('tutors').doc(tutor.uid).update(tutor.toMap());
  }

  Future<void> deleteTutor(String uid) async {
    await _db.collection('tutors').doc(uid).delete();
  }
}

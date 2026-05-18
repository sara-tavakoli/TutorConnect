import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Wraps Firebase Auth and Firestore for all authentication and user-profile operations.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  /// Emits a [User] whenever sign-in state changes (login, logout, token refresh).
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Creates a Firebase Auth account, writes a Firestore user doc, and
  /// (for tutors) creates the matching tutor profile document.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      role: role,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(user.uid).set(user.toMap());

    if (role == UserRole.tutor) {
      await _db.collection('tutors').doc(user.uid).set({
        'name': user.name,
        'bio': '',
        'subjects': <String>[],
        'hourlyRate': 30.0,
        'availability': <String>[],
        'rating': 0.0,
        'reviewCount': 0,
        'photoUrl': null,
        'university': null,
        'year': null,
      });
    }

    return user;
  }

  /// Signs in with email/password and returns the matching Firestore user profile.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final doc = await _db
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> signOut() => _auth.signOut();

  /// Fetches the Firestore user profile for [uid]. Returns null if not found.
  Future<UserModel?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}

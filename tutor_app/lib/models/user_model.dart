import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, tutor }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.createdAt,
  });

  bool get isTutor  => role == UserRole.tutor;
  bool get isStudent => role == UserRole.student;

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] == 'tutor' ? UserRole.tutor : UserRole.student,
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'role': role.name,
    'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({String? name, String? photoUrl}) => UserModel(
    uid: uid,
    name: name ?? this.name,
    email: email,
    role: role,
    photoUrl: photoUrl ?? this.photoUrl,
    createdAt: createdAt,
  );
}

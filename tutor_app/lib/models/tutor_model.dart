import 'package:cloud_firestore/cloud_firestore.dart';

class TutorModel {
  final String uid;
  final String name;
  final String? photoUrl;
  final String bio;
  final List<String> subjects;
  final double hourlyRate;
  final List<String> availability;
  final double rating;
  final int reviewCount;
  final String? university;
  final String? year;

  const TutorModel({
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.bio,
    required this.subjects,
    required this.hourlyRate,
    required this.availability,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.university,
    this.year,
  });

  factory TutorModel.fromMap(Map<String, dynamic> map, String uid) {
    return TutorModel(
      uid: uid,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String? ?? '',
      subjects: List<String>.from(map['subjects'] as List? ?? []),
      hourlyRate: (map['hourlyRate'] as num? ?? 0).toDouble(),
      availability: List<String>.from(map['availability'] as List? ?? []),
      rating: (map['rating'] as num? ?? 0).toDouble(),
      reviewCount: map['reviewCount'] as int? ?? 0,
      university: map['university'] as String?,
      year: map['year'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'photoUrl': photoUrl,
    'bio': bio,
    'subjects': subjects,
    'hourlyRate': hourlyRate,
    'availability': availability,
    'rating': rating,
    'reviewCount': reviewCount,
    'university': university,
    'year': year,
  };

  TutorModel copyWith({
    String? name,
    String? photoUrl,
    String? bio,
    List<String>? subjects,
    double? hourlyRate,
    List<String>? availability,
    String? university,
    String? year,
  }) => TutorModel(
    uid: uid,
    name: name ?? this.name,
    photoUrl: photoUrl ?? this.photoUrl,
    bio: bio ?? this.bio,
    subjects: subjects ?? this.subjects,
    hourlyRate: hourlyRate ?? this.hourlyRate,
    availability: availability ?? this.availability,
    rating: rating,
    reviewCount: reviewCount,
    university: university ?? this.university,
    year: year ?? this.year,
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String   id;
  final String   tutorId;
  final String   studentId;
  final String   studentName;
  final double   rating;
  final String   comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.studentName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id:          id,
      tutorId:     map['tutorId']     as String,
      studentId:   map['studentId']   as String,
      studentName: map['studentName'] as String,
      rating:      (map['rating']     as num).toDouble(),
      comment:     map['comment']     as String,
      createdAt:   (map['createdAt']  as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'tutorId':     tutorId,
    'studentId':   studentId,
    'studentName': studentName,
    'rating':      rating,
    'comment':     comment,
    'createdAt':   Timestamp.fromDate(createdAt),
  };
}
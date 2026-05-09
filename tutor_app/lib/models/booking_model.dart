import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class BookingModel {
  final String id;
  final String studentId;
  final String studentName;
  final String tutorId;
  final String tutorName;
  final String subject;
  final String slot;
  final BookingStatus status;
  final DateTime createdAt;
  final String? note;

  const BookingModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.tutorId,
    required this.tutorName,
    required this.subject,
    required this.slot,
    required this.status,
    required this.createdAt,
    this.note,
  });

  bool get isPending   => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isCompleted => status == BookingStatus.completed;

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id:          id,
      studentId:   map['studentId']   as String,
      studentName: map['studentName'] as String,
      tutorId:     map['tutorId']     as String,
      tutorName:   map['tutorName']   as String,
      subject:     map['subject']     as String,
      slot:        map['slot']        as String,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'studentId':   studentId,
    'studentName': studentName,
    'tutorId':     tutorId,
    'tutorName':   tutorName,
    'subject':     subject,
    'slot':        slot,
    'status':      status.name,
    'createdAt':   Timestamp.fromDate(createdAt),
    'note':        note,
  };

  BookingModel copyWith({BookingStatus? status}) => BookingModel(
    id:          id,
    studentId:   studentId,
    studentName: studentName,
    tutorId:     tutorId,
    tutorName:   tutorName,
    subject:     subject,
    slot:        slot,
    status:      status ?? this.status,
    createdAt:   createdAt,
    note:        note,
  );
}

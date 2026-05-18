import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String   id;
  final String   senderId;
  final String   text;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id:        id,
      senderId:  map['senderId'] as String,
      text:      map['text']     as String,
      // serverTimestamp can be null during offline write
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId':  senderId,
    'text':      text,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

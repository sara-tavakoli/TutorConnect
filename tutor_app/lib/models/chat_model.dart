import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String              id;
  final List<String>        participants;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String              lastMessage;
  final DateTime?           lastMessageAt;
  final Map<String, int>    unreadCounts;

  const ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantPhotos,
    required this.lastMessage,
    required this.unreadCounts,
    this.lastMessageAt,
  });

  String otherUserId(String myUid) =>
      participants.firstWhere((p) => p != myUid, orElse: () => '');

  String otherUserName(String myUid) =>
      participantNames[otherUserId(myUid)] ?? 'User';

  String? otherUserPhoto(String myUid) =>
      participantPhotos[otherUserId(myUid)];

  int unreadFor(String uid) => unreadCounts[uid] ?? 0;

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    final namesRaw   = map['participantNames']  as Map? ?? {};
    final photosRaw  = map['participantPhotos'] as Map? ?? {};
    final unreadRaw  = map['unreadCounts']      as Map? ?? {};

    return ChatModel(
      id:               id,
      participants:     List<String>.from(map['participants'] as List? ?? []),
      participantNames: namesRaw.map(
          (k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
      participantPhotos: photosRaw.map(
          (k, v) => MapEntry(k.toString(), v?.toString())),
      lastMessage:    map['lastMessage']   as String?  ?? '',
      lastMessageAt:  map['lastMessageAt'] != null
          ? (map['lastMessageAt'] as Timestamp).toDate()
          : null,
      unreadCounts: unreadRaw.map(
          (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0)),
    );
  }
}

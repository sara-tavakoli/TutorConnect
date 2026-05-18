import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

/// Manages real-time 1-to-1 chat conversations stored in Firestore.
class ChatService {
  final FirebaseFirestore _db;

  ChatService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // Deterministic chat ID — same pair always maps to the same doc
  String _chatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  // Get or create a 1-to-1 chat, returns the chatId
  Future<String> getOrCreateChat({
    required String uid1,
    required String name1,
    required String uid2,
    required String name2,
    String? photo1,
    String? photo2,
  }) async {
    final chatId  = _chatId(uid1, uid2);
    final chatRef = _db.collection('chats').doc(chatId);

    final snap = await chatRef.get();
    if (!snap.exists) {
      await chatRef.set({
        'participants':      [uid1, uid2],
        'participantNames':  {uid1: name1, uid2: name2},
        'participantPhotos': {uid1: photo1, uid2: photo2},
        'lastMessage':       '',
        'lastMessageAt':     FieldValue.serverTimestamp(),
        'unreadCounts':      {uid1: 0, uid2: 0},
      });
    }
    return chatId;
  }

  // Send a message and update chat metadata in a single batch
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final chatRef    = _db.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    final batch = _db.batch();
    batch.set(messageRef, {
      'senderId':  senderId,
      'text':      text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(chatRef, {
      'lastMessage':                   text.trim(),
      'lastMessageAt':                 FieldValue.serverTimestamp(),
      'unreadCounts.$receiverId':      FieldValue.increment(1),
    });
    await batch.commit();
  }

  // Stream messages for a chat, oldest first
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Stream all chats for a user, sorted by most recent activity (client-side)
  Stream<List<ChatModel>> getChats(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final chats = snap.docs
          .map((d) => ChatModel.fromMap(d.data(), d.id))
          .toList();
      chats.sort((a, b) {
        if (a.lastMessageAt == null) return 1;
        if (b.lastMessageAt == null) return -1;
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      });
      return chats;
    });
  }

  // Mark all messages in a chat as read for a user
  Future<void> markAsRead(String chatId, String uid) async {
    await _db.collection('chats').doc(chatId).update({
      'unreadCounts.$uid': 0,
    });
  }

  // Stream total unread count across all chats (for nav badge)
  Stream<int> getTotalUnread(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs.fold<int>(0, (total, doc) {
              final counts = Map<String, dynamic>.from(
                  doc.data()['unreadCounts'] as Map? ?? {});
              return total + ((counts[uid] as num?)?.toInt() ?? 0);
            }));
  }
}

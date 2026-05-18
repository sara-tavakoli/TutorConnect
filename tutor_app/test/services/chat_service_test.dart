import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/services/chat_service.dart';

void main() {
  late FakeFirebaseFirestore db;
  late ChatService service;

  setUp(() {
    db      = FakeFirebaseFirestore();
    service = ChatService(db: db);
  });

  group('ChatService.getOrCreateChat', () {
    test('creates a chat doc and returns a deterministic id', () async {
      final id = await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice',
        uid2: 'bob',   name2: 'Bob',
      );
      expect(id, isNotEmpty);
      final doc = await db.collection('chats').doc(id).get();
      expect(doc.exists, isTrue);
      expect((doc.data()!['participants'] as List), containsAll(['alice', 'bob']));
    });

    test('same pair always produces the same chat id', () async {
      final id1 = await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      final id2 = await service.getOrCreateChat(
        uid1: 'bob', name1: 'Bob', uid2: 'alice', name2: 'Alice',
      );
      expect(id1, equals(id2));
    });

    test('calling twice does not create a second document', () async {
      await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      final snap = await db.collection('chats').get();
      expect(snap.docs.length, 1);
    });
  });

  group('ChatService.sendMessage', () {
    test('creates a message document in the chat subcollection', () async {
      final chatId = await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      await service.sendMessage(
        chatId: chatId, senderId: 'alice',
        receiverId: 'bob', text: 'Hello!',
      );
      final msgs = await db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      expect(msgs.docs.length, 1);
      expect(msgs.docs.first.data()['text'], 'Hello!');
    });

    test('updates lastMessage on the chat doc', () async {
      final chatId = await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      await service.sendMessage(
        chatId: chatId, senderId: 'alice',
        receiverId: 'bob', text: 'Hi there',
      );
      final doc = await db.collection('chats').doc(chatId).get();
      expect(doc.data()!['lastMessage'], 'Hi there');
    });
  });

  group('ChatService.getMessages', () {
    test('returns an empty list when no messages exist', () async {
      final chatId = await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      final messages = await service.getMessages(chatId).first;
      expect(messages, isEmpty);
    });

    test('streams messages after sending', () async {
      final chatId = await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      await service.sendMessage(
        chatId: chatId, senderId: 'alice',
        receiverId: 'bob', text: 'Test message',
      );
      final messages = await service.getMessages(chatId).first;
      expect(messages.length, 1);
      expect(messages.first.text, 'Test message');
      expect(messages.first.senderId, 'alice');
    });
  });

  group('ChatService.getChats', () {
    test('returns chats where user is a participant', () async {
      await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      final chats = await service.getChats('alice').first;
      expect(chats.length, 1);
    });

    test('does not return chats for non-participant', () async {
      await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      final chats = await service.getChats('carol').first;
      expect(chats, isEmpty);
    });
  });

  group('ChatService.markAsRead', () {
    test('sets unread count to 0 for the given user', () async {
      final chatId = await service.getOrCreateChat(
        uid1: 'alice', name1: 'Alice', uid2: 'bob', name2: 'Bob',
      );
      await service.sendMessage(
        chatId: chatId, senderId: 'alice',
        receiverId: 'bob', text: 'Hey',
      );
      await service.markAsRead(chatId, 'bob');
      final doc = await db.collection('chats').doc(chatId).get();
      final counts = Map<String, dynamic>.from(
          doc.data()!['unreadCounts'] as Map);
      expect(counts['bob'], 0);
    });
  });
}

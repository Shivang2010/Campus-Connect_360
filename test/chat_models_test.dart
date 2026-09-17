import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_360/app/modules/chat/models/chat_model.dart';
import 'package:campus_connect_360/app/modules/chat/models/message_model.dart';

void main() {
  group('Chat & Message Models Unit Tests', () {
    test('getChatId creates deterministic ID regardless of argument order', () {
      final id1 = ChatModel.getChatId('user_alpha', 'user_beta');
      final id2 = ChatModel.getChatId('user_beta', 'user_alpha');

      expect(id1, 'user_alpha_user_beta');
      expect(id1, equals(id2));
    });

    test('ChatModel serialization & helper methods work properly', () {
      final now = DateTime.now();
      final model = ChatModel(
        id: 'chat_123',
        participants: ['user_a', 'user_b'],
        participantNames: {'user_a': 'Alice', 'user_b': 'Bob'},
        lastMessage: 'Hey there!',
        lastMessageTime: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(model.getOtherUserId('user_a'), 'user_b');
      expect(model.getOtherUserName('user_a'), 'Bob');
      expect(model.getOtherUserName('user_b'), 'Alice');

      final json = model.toJson();
      expect(json['lastMessage'], 'Hey there!');
      expect(json['participants'], contains('user_a'));

      final reconstructed = ChatModel.fromJson(json, 'chat_123');
      expect(reconstructed.id, 'chat_123');
      expect(reconstructed.lastMessage, 'Hey there!');
    });

    test('MessageModel serialization works properly', () {
      final now = DateTime.now();
      final msg = MessageModel(
        id: 'msg_001',
        senderId: 'user_a',
        receiverId: 'user_b',
        message: 'Where are you?',
        messageType: 'text',
        createdAt: now,
        isRead: false,
      );

      final json = msg.toJson();
      expect(json['message'], 'Where are you?');
      expect(json['isRead'], false);

      final reconstructed = MessageModel.fromJson(json, 'msg_001');
      expect(reconstructed.id, 'msg_001');
      expect(reconstructed.message, 'Where are you?');
      expect(reconstructed.senderId, 'user_a');
      expect(reconstructed.receiverId, 'user_b');
    });
  });
}

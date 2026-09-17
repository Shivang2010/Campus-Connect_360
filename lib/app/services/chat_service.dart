import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../modules/chat/models/chat_model.dart';
import '../modules/chat/models/message_model.dart';

/// Service responsible for all direct interactions with Cloud Firestore
/// for real-time messaging and chat room management.
class ChatService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chatsRef =>
      _firestore.collection('chats');

  // ─────────────────────────────────────────────────────────────
  // 1. Get or Create 1-to-1 Chat Conversation
  // ─────────────────────────────────────────────────────────────

  /// Ensures a chat document exists between [currentUserId] and [otherUserId].
  /// If it already exists, returns the existing chatId.
  /// If not, creates it with initial metadata.
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    final chatId = ChatModel.getChatId(currentUserId, otherUserId);
    final docRef = _chatsRef.doc(chatId);
    final snapshot = await docRef.get();

    // Fetch actual names from the users collection if possible to avoid generic placeholders like 'Seller' or 'Item Owner'
    String resolvedCurrentName = currentUserName;
    String resolvedOtherName = otherUserName;

    try {
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (currentUserDoc.exists && currentUserDoc.data()?['name'] != null) {
        resolvedCurrentName = currentUserDoc.data()?['name'];
      }
      final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
      if (otherUserDoc.exists && otherUserDoc.data()?['name'] != null) {
        resolvedOtherName = otherUserDoc.data()?['name'];
      }
    } catch (e) {
      debugPrint('[ChatService] Error resolving user names: $e');
    }

    if (!snapshot.exists) {
      final now = DateTime.now();
      final newChat = ChatModel(
        id: chatId,
        participants: [currentUserId, otherUserId],
        participantNames: {
          currentUserId: resolvedCurrentName,
          otherUserId: resolvedOtherName,
        },
        lastMessage: '',
        lastMessageTime: null,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(newChat.toJson());
    } else {
      // If the chat room already exists but has placeholder names, we update them
      final data = snapshot.data();
      final currentNames = data?['participantNames'] as Map?;
      if (currentNames != null &&
          (currentNames[otherUserId] == 'Seller' ||
              currentNames[otherUserId] == 'Item Owner' ||
              currentNames[otherUserId] == 'Item Finder' ||
              currentNames[otherUserId] == 'Student (Note Contributor)')) {
        await docRef.update({
          'participantNames.$currentUserId': resolvedCurrentName,
          'participantNames.$otherUserId': resolvedOtherName,
        });
      }
    }

    return chatId;
  }

  // ─────────────────────────────────────────────────────────────
  // 2. Real-time Streams
  // ─────────────────────────────────────────────────────────────

  /// Real-time stream of all conversations where [userId] is a participant.
  /// Sorted client-side by [updatedAt] descending (latest activity at the top).
  ///
  /// NOTE: We intentionally avoid `.orderBy('updatedAt')` in the Firestore query
  /// because combining `arrayContains` with `orderBy` on a different field
  /// requires a composite index. Without that index Firestore silently returns
  /// an empty stream. Sorting in Dart achieves the same result without the index.
  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _chatsRef
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) {
        return ChatModel.fromJson(doc.data(), doc.id);
      }).toList();
      // Sort client-side: most recently active chat first
      chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return chats;
    });
  }

  /// Real-time stream of messages inside a specific [chatId].
  /// Ordered chronologically by [createdAt] ascending so messages read from top to bottom.
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  // ─────────────────────────────────────────────────────────────
  // 3. Send Message
  // ─────────────────────────────────────────────────────────────

  /// Sends a text message, saves it into the subcollection, and updates the parent chat metadata.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String messageText,
  }) async {
    final cleanText = messageText.trim();
    if (cleanText.isEmpty) return;

    final now = DateTime.now();

    // 1. Add message to chats/{chatId}/messages
    final messageDoc = _chatsRef.doc(chatId).collection('messages').doc();
    final message = MessageModel(
      id: messageDoc.id,
      senderId: senderId,
      receiverId: receiverId,
      message: cleanText,
      messageType: 'text',
      createdAt: now,
      isRead: false,
    );

    await messageDoc.set(message.toJson());

    // 2. Update parent chat document with snippet of last message
    await _chatsRef.doc(chatId).update({
      'lastMessage': cleanText,
      'lastMessageTime': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  // ─────────────────────────────────────────────────────────────
  // 4. Mark Messages as Read
  // ─────────────────────────────────────────────────────────────

  /// Marks all unread messages received by [currentUserId] in [chatId] as read.
  Future<void> markMessagesAsRead({
    required String chatId,
    required String currentUserId,
  }) async {
    final unreadQuery = await _chatsRef
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    if (unreadQuery.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unreadQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}

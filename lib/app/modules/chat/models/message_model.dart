import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single message within a chat conversation.
/// Stored in Firestore subcollection: `chats/{chatId}/messages/{messageId}`
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String messageType; // 'text', and extensible for 'image' or 'file'
  final DateTime createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.messageType = 'text',
    required this.createdAt,
    this.isRead = false,
  });

  /// Factory to convert a Firestore document snapshot into a [MessageModel].
  factory MessageModel.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return MessageModel(
      id: docId,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      messageType: json['messageType'] ?? 'text',
      createdAt: parseDate(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  /// Converts the [MessageModel] into a Map for Firestore write operations.
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'messageType': messageType,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a 1-to-1 conversation metadata document in Firestore.
/// Stored in Firestore collection: `chats/{chatId}`
class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames; // e.g. { uid1: "Shivang", uid2: "Rahul" }
  final String lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deterministic Chat ID generator:
  /// Always sorts both UIDs alphabetically and joins with an underscore.
  /// Example: sorted(["uidB", "uidA"]).join('_') -> "uidA_uidB"
  /// This guarantees that between two users, only one chat document ever exists.
  static String getChatId(String user1, String user2) {
    final sorted = [user1, user2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Helper to get the other participant's UID given the current user's UID.
  String getOtherUserId(String currentUserId) {
    return participants.firstWhere(
      (uid) => uid != currentUserId,
      orElse: () => '',
    );
  }

  /// Helper to get the other participant's display name.
  String getOtherUserName(String currentUserId) {
    final otherUid = getOtherUserId(currentUserId);
    return participantNames[otherUid] ?? 'Student';
  }

  /// Factory to convert a Firestore document snapshot into a [ChatModel].
  factory ChatModel.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    // Safely parse participantNames map
    final rawNames = json['participantNames'];
    final Map<String, String> parsedNames = {};
    if (rawNames is Map) {
      rawNames.forEach((key, value) {
        parsedNames[key.toString()] = value.toString();
      });
    }

    return ChatModel(
      id: docId,
      participants: List<String>.from(json['participants'] ?? []),
      participantNames: parsedNames,
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? parseDate(json['lastMessageTime'])
          : null,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  /// Converts the [ChatModel] into a Map for Firestore write operations.
  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

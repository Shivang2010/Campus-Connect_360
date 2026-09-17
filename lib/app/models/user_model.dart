import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  // Factory constructor to create a UserModel from a Firestore document map
  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        parsedDate = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        parsedDate = DateTime.tryParse(json['createdAt']);
      }
    }

    return UserModel(
      uid: uid,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Student',
      createdAt: parsedDate,
    );
  }

  // Convert UserModel instance to Map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

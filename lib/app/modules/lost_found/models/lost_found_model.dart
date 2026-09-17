import 'package:cloud_firestore/cloud_firestore.dart';

class LostFoundModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String type; // 'Lost' or 'Found'
  final String reportedBy; // UID of reporter
  final DateTime? createdAt;
  final String? imageUrl;
  final String status; // 'Active' or 'Resolved'

  LostFoundModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.reportedBy,
    this.createdAt,
    this.imageUrl,
    this.status = 'Active',
  });

  factory LostFoundModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        parsedDate = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        parsedDate = DateTime.tryParse(json['createdAt']);
      }
    }

    return LostFoundModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? 'Lost',
      reportedBy: json['reportedBy'] ?? '',
      createdAt: parsedDate,
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'type': type,
      'reportedBy': reportedBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'status': status,
    };
  }
}

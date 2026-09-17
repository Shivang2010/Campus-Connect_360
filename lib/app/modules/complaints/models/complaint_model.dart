import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String reportedBy; // UID of reporter
  final String status; // 'Reported', 'Assigned', 'In Progress', 'Resolved'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.reportedBy,
    this.status = 'Reported',
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parsedCreated;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        parsedCreated = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        parsedCreated = DateTime.tryParse(json['createdAt']);
      }
    }

    DateTime? parsedUpdated;
    if (json['updatedAt'] != null) {
      if (json['updatedAt'] is Timestamp) {
        parsedUpdated = (json['updatedAt'] as Timestamp).toDate();
      } else if (json['updatedAt'] is String) {
        parsedUpdated = DateTime.tryParse(json['updatedAt']);
      }
    }

    return ComplaintModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      reportedBy: json['reportedBy'] ?? '',
      status: json['status'] ?? 'Reported',
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'reportedBy': reportedBy,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}

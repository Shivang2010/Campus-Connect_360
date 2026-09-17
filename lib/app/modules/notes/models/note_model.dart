import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String subject;
  final String description;
  final String? fileUrl;
  final String uploadedBy;
  final DateTime? createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    this.fileUrl,
    required this.uploadedBy,
    this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        parsedDate = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        parsedDate = DateTime.tryParse(json['createdAt']);
      }
    }

    return NoteModel(
      id: id,
      title: json['title'] ?? '',
      subject: json['subject'] ?? 'General',
      description: json['description'] ?? '',
      fileUrl: json['fileUrl'],
      uploadedBy: json['uploadedBy'] ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
      'description': description,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

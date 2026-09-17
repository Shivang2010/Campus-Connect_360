import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String date; // Format: e.g. "2026-10-15" or "15 Oct 2026"
  final String time; // Format: e.g. "05:00 PM"
  final String location;
  final String createdBy; // UID of creator/admin
  final DateTime? createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.createdBy,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        parsedDate = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        parsedDate = DateTime.tryParse(json['createdAt']);
      }
    }

    return EventModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

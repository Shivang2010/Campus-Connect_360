import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String condition; // e.g. 'New', 'Like New', 'Used - Good', 'Fair'
  final String sellerId;
  final String? imageUrl;
  final DateTime? createdAt;
  final String status; // 'Available' or 'Sold'

  MarketplaceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.condition,
    required this.sellerId,
    this.imageUrl,
    this.createdAt,
    this.status = 'Available',
  });

  factory MarketplaceModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        parsedDate = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        parsedDate = DateTime.tryParse(json['createdAt']);
      }
    }

    double parsedPrice = 0.0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      } else if (json['price'] is String) {
        parsedPrice = double.tryParse(json['price']) ?? 0.0;
      }
    }

    return MarketplaceModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: parsedPrice,
      condition: json['condition'] ?? 'Used - Good',
      sellerId: json['sellerId'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: parsedDate,
      status: json['status'] ?? 'Available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'condition': condition,
      'sellerId': sellerId,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'status': status,
    };
  }
}

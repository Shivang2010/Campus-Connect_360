import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_360/app/modules/lost_found/models/lost_found_model.dart';

void main() {
  group('LostFoundModel Unit Tests', () {
    test('toJson and fromJson serialization works correctly', () {
      final now = DateTime.now();
      final model = LostFoundModel(
        id: 'test_doc_123',
        title: 'Blue Backpack',
        description: 'Left in Room 302',
        location: 'Academic Block A',
        type: 'Lost',
        reportedBy: 'user_456',
        createdAt: now,
        status: 'Active',
      );

      final json = model.toJson();
      expect(json['title'], 'Blue Backpack');
      expect(json['description'], 'Left in Room 302');
      expect(json['location'], 'Academic Block A');
      expect(json['type'], 'Lost');
      expect(json['reportedBy'], 'user_456');

      final reconstructed = LostFoundModel.fromJson(json, 'test_doc_123');
      expect(reconstructed.id, 'test_doc_123');
      expect(reconstructed.title, 'Blue Backpack');
      expect(reconstructed.type, 'Lost');
    });
  });
}

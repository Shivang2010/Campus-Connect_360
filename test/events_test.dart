import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_360/app/modules/events/models/event_model.dart';

void main() {
  group('EventModel Unit Tests', () {
    test('toJson and fromJson work cleanly for Events', () {
      final now = DateTime.now();
      final event = EventModel(
        id: 'event_123',
        title: 'Tech Fest 2026',
        description: 'Annual inter-college technology contest',
        date: '20 Oct 2026',
        time: '10:00 AM',
        location: 'Seminar Hall B',
        createdBy: 'admin_uid_77',
        createdAt: now,
      );

      final json = event.toJson();
      expect(json['title'], 'Tech Fest 2026');
      expect(json['date'], '20 Oct 2026');
      expect(json['time'], '10:00 AM');
      expect(json['location'], 'Seminar Hall B');

      final reconstructed = EventModel.fromJson(json, 'event_123');
      expect(reconstructed.id, 'event_123');
      expect(reconstructed.title, 'Tech Fest 2026');
    });
  });
}

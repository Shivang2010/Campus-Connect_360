import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_360/app/modules/complaints/models/complaint_model.dart';

void main() {
  group('ComplaintModel Unit Tests', () {
    test('toJson and fromJson work cleanly for Complaints', () {
      final now = DateTime.now();
      final complaint = ComplaintModel(
        id: 'comp_555',
        title: 'Projector Not Working',
        description: 'HDMI port loose in LH 101',
        location: 'Lecture Hall 101',
        reportedBy: 'student_99',
        status: 'In Progress',
        createdAt: now,
        updatedAt: now,
      );

      final json = complaint.toJson();
      expect(json['title'], 'Projector Not Working');
      expect(json['status'], 'In Progress');
      expect(json['location'], 'Lecture Hall 101');

      final reconstructed = ComplaintModel.fromJson(json, 'comp_555');
      expect(reconstructed.id, 'comp_555');
      expect(reconstructed.status, 'In Progress');
    });
  });
}

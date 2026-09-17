import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_360/app/modules/notes/models/note_model.dart';

void main() {
  group('NoteModel Unit Tests', () {
    test('toJson and fromJson work cleanly for Notes', () {
      final now = DateTime.now();
      final note = NoteModel(
        id: 'note_888',
        title: 'Data Structures Unit 2 Notes',
        subject: 'Computer Science',
        description: 'Complete notes on Stacks, Queues and Linked Lists',
        uploadedBy: 'student_uid_101',
        createdAt: now,
      );

      final json = note.toJson();
      expect(json['title'], 'Data Structures Unit 2 Notes');
      expect(json['subject'], 'Computer Science');
      expect(json['uploadedBy'], 'student_uid_101');

      final reconstructed = NoteModel.fromJson(json, 'note_888');
      expect(reconstructed.id, 'note_888');
      expect(reconstructed.subject, 'Computer Science');
    });
  });
}

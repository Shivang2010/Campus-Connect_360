import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_360/app/models/user_model.dart';

void main() {
  group('Admin Management Unit Tests', () {
    test('UserModel role update works cleanly', () {
      final now = DateTime.now();
      final user = UserModel(
        uid: 'user_777',
        name: 'Alex Johnson',
        email: 'alex@campus.edu',
        role: 'Student',
        createdAt: now,
      );

      expect(user.role, 'Student');

      final updatedUser = UserModel(
        uid: user.uid,
        name: user.name,
        email: user.email,
        role: 'Admin',
        createdAt: user.createdAt,
      );

      expect(updatedUser.role, 'Admin');
      expect(updatedUser.toJson()['role'], 'Admin');
    });
  });
}

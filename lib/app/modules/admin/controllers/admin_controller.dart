import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive list of all registered users
  RxList<UserModel> userList = <UserModel>[].obs;

  // Search state for users
  RxString searchQuery = ''.obs;

  // Loading state
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind real-time stream from users collection
    userList.bindStream(
      _firestore.collection('users').snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => UserModel.fromJson(doc.data(), doc.id))
                .toList(),
          ),
    );
  }

  // Filter users by name or email search query
  List<UserModel> get filteredUsers {
    if (searchQuery.value.trim().isEmpty) return userList;
    final query = searchQuery.value.toLowerCase();
    return userList
        .where((user) =>
            user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query))
        .toList();
  }

  // Promote or Demote a user's role ('Student' <-> 'Admin')
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      isLoading.value = true;
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
      });
      Get.snackbar(
        'Role Updated',
        'User role updated to $newRole',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update user role: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

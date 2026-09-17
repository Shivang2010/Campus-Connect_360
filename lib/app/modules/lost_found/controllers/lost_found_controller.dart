import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../models/lost_found_model.dart';

class LostFoundController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive list of all Lost & Found items
  RxList<LostFoundModel> itemList = <LostFoundModel>[].obs;

  // Currently active filter ('All', 'Lost', 'Found')
  RxString selectedFilter = 'All'.obs;

  // Reactive loading state for form submission
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind real-time stream from Cloud Firestore lost_found collection
    itemList.bindStream(
      _firestore
          .collection('lost_found')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => LostFoundModel.fromJson(doc.data(), doc.id))
                .toList(),
          ),
    );
  }

  // Getter to return filtered items based on selectedFilter
  List<LostFoundModel> get filteredItems {
    if (selectedFilter.value == 'Lost') {
      return itemList.where((item) => item.type == 'Lost').toList();
    } else if (selectedFilter.value == 'Found') {
      return itemList.where((item) => item.type == 'Found').toList();
    }
    return itemList;
  }

  // Create a new Lost/Found report in Firestore
  Future<void> createReport({
    required String title,
    required String description,
    required String location,
    required String type,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a title');
      return;
    }
    if (description.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a description');
      return;
    }
    if (location.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter the location');
      return;
    }

    final AuthController authController = Get.find<AuthController>();
    final String? uid = authController.userModel.value?.uid;

    if (uid == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      isLoading.value = true;

      LostFoundModel newItem = LostFoundModel(
        id: '',
        title: title.trim(),
        description: description.trim(),
        location: location.trim(),
        type: type,
        reportedBy: uid,
        createdAt: DateTime.now(),
        status: 'Active',
      );

      await _firestore.collection('lost_found').add(newItem.toJson());

      Get.back(); // Close the report modal/bottom sheet
      Get.snackbar(
        'Success',
        'Report created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not create report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a report (only allowed for owner or admin)
  Future<void> deleteReport(String docId) async {
    try {
      await _firestore.collection('lost_found').doc(docId).delete();
      Get.snackbar(
        'Success',
        'Report deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Toggle report status between 'Active' and 'Resolved'
  Future<void> toggleReportStatus(String docId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'Active' ? 'Resolved' : 'Active';
      await _firestore.collection('lost_found').doc(docId).update({
        'status': newStatus,
      });
      Get.snackbar(
        'Status Updated',
        'Item status marked as $newStatus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not update status: $e');
    }
  }
}

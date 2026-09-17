import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../models/complaint_model.dart';

class ComplaintsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive list of all complaints
  RxList<ComplaintModel> complaintList = <ComplaintModel>[].obs;

  // Active filter state
  RxString selectedFilter = 'All'.obs;

  // Loading state
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind real-time stream from Cloud Firestore complaints collection
    complaintList.bindStream(
      _firestore
          .collection('complaints')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ComplaintModel.fromJson(doc.data(), doc.id))
                .toList(),
          ),
    );
  }

  // Filter complaints based on active filter
  List<ComplaintModel> get filteredComplaints {
    final AuthController authController = Get.find<AuthController>();
    final String currentUid = authController.userModel.value?.uid ?? '';

    return complaintList.where((complaint) {
      if (selectedFilter.value == 'My Complaints') {
        return complaint.reportedBy == currentUid;
      } else if (selectedFilter.value == 'Reported') {
        return complaint.status == 'Reported';
      } else if (selectedFilter.value == 'In Progress') {
        return complaint.status == 'In Progress' || complaint.status == 'Assigned';
      } else if (selectedFilter.value == 'Resolved') {
        return complaint.status == 'Resolved';
      }
      return true;
    }).toList();
  }

  // Submit a new complaint (Student functionality)
  Future<void> createComplaint({
    required String title,
    required String location,
    required String description,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a complaint title');
      return;
    }
    if (location.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter the issue location');
      return;
    }
    if (description.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please describe the issue');
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

      ComplaintModel newComplaint = ComplaintModel(
        id: '',
        title: title.trim(),
        location: location.trim(),
        description: description.trim(),
        reportedBy: uid,
        status: 'Reported',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('complaints').add(newComplaint.toJson());

      Get.back(); // Close bottom sheet
      Get.snackbar(
        'Success',
        'Complaint submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not submit complaint: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update complaint status (Admin functionality: Reported -> Assigned -> In Progress -> Resolved)
  Future<void> updateComplaintStatus(String docId, String newStatus) async {
    try {
      await _firestore.collection('complaints').doc(docId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        'Status Updated',
        'Complaint status updated to $newStatus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete complaint (Owner or Admin)
  Future<void> deleteComplaint(String docId) async {
    try {
      await _firestore.collection('complaints').doc(docId).delete();
      Get.snackbar(
        'Success',
        'Complaint deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete complaint: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

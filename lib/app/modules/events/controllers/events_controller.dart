import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../models/event_model.dart';

class EventsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive list of all events
  RxList<EventModel> eventList = <EventModel>[].obs;

  // Search query state
  RxString searchQuery = ''.obs;

  // Loading state for event creation
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind real-time Firestore stream from events collection
    eventList.bindStream(
      _firestore
          .collection('events')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => EventModel.fromJson(doc.data(), doc.id))
                .toList(),
          ),
    );
  }

  // Filtered events by search keyword
  List<EventModel> get filteredEvents {
    if (searchQuery.value.trim().isEmpty) return eventList;
    final query = searchQuery.value.toLowerCase();
    return eventList
        .where((event) =>
            event.title.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query) ||
            event.location.toLowerCase().contains(query))
        .toList();
  }

  // Create a new Campus Event (Admin functionality)
  Future<void> createEvent({
    required String title,
    required String description,
    required String date,
    required String time,
    required String location,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter an event title');
      return;
    }
    if (date.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please select an event date');
      return;
    }
    if (time.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please select an event time');
      return;
    }
    if (location.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter the location');
      return;
    }
    if (description.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter an event description');
      return;
    }

    final AuthController authController = Get.find<AuthController>();
    final user = authController.userModel.value;

    if (user == null || user.role != 'Admin') {
      Get.snackbar('Permission Denied', 'Only Admins can create campus events');
      return;
    }

    try {
      isLoading.value = true;

      EventModel newEvent = EventModel(
        id: '',
        title: title.trim(),
        description: description.trim(),
        date: date.trim(),
        time: time.trim(),
        location: location.trim(),
        createdBy: user.uid,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('events').add(newEvent.toJson());

      Get.back(); // Close modal sheet
      Get.snackbar(
        'Success',
        'Campus event created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not create event: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete an event (Admin functionality)
  Future<void> deleteEvent(String docId) async {
    final AuthController authController = Get.find<AuthController>();
    final user = authController.userModel.value;

    if (user == null || user.role != 'Admin') {
      Get.snackbar('Permission Denied', 'Only Admins can delete events');
      return;
    }

    try {
      await _firestore.collection('events').doc(docId).delete();
      Get.snackbar(
        'Success',
        'Event deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete event: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

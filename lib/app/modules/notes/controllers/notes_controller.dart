import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../models/note_model.dart';

class NotesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive list of all academic notes
  RxList<NoteModel> noteList = <NoteModel>[].obs;

  // Search and Filter states
  RxString searchQuery = ''.obs;
  RxString selectedSubject = 'All'.obs;

  // Loading state
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind real-time stream from Cloud Firestore notes collection
    noteList.bindStream(
      _firestore
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => NoteModel.fromJson(doc.data(), doc.id))
                .toList(),
          ),
    );
  }

  // Filter notes by search keyword and subject tag
  List<NoteModel> get filteredNotes {
    return noteList.where((note) {
      final matchesQuery = searchQuery.value.trim().isEmpty ||
          note.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          note.subject.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          note.description.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesSubject = selectedSubject.value == 'All' ||
          note.subject == selectedSubject.value;

      return matchesQuery && matchesSubject;
    }).toList();
  }

  // Upload/Share a new note
  Future<void> uploadNote({
    required String title,
    required String subject,
    required String description,
    String? fileUrl,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a note title');
      return;
    }
    if (subject.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please select or enter a subject');
      return;
    }
    if (description.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter note description');
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

      NoteModel newNote = NoteModel(
        id: '',
        title: title.trim(),
        subject: subject.trim(),
        description: description.trim(),
        fileUrl: fileUrl?.trim(),
        uploadedBy: uid,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notes').add(newNote.toJson());

      Get.back(); // Close modal sheet
      Get.snackbar(
        'Success',
        'Academic note shared successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not share note: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete note (uploader or admin)
  Future<void> deleteNote(String docId) async {
    try {
      await _firestore.collection('notes').doc(docId).delete();
      Get.snackbar(
        'Success',
        'Note deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete note: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

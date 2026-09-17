import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/notes_controller.dart';
import '../models/note_model.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  void _showUploadNoteSheet(BuildContext context, NotesController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _UploadNoteBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotesController());
    final AuthController authController = Get.find<AuthController>();
    final String currentUid = authController.userModel.value?.uid ?? '';
    final bool isAdmin = authController.userModel.value?.role == 'Admin';
    final theme = Theme.of(context);

    final subjects = ['All', 'Computer Science', 'Mathematics', 'Physics', 'Electronics', 'General'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Notes & Materials', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Subject Filter Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search notes by title or subject...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Subject Filter Chips
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: subjects.map((subj) {
                        final isSelected =
                            controller.selectedSubject.value == subj;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(subj),
                            selected: isSelected,
                            selectedColor: theme.primaryColor.withAlpha(40),
                            labelStyle: TextStyle(
                              color: isSelected ? theme.primaryColor : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedSubject.value = subj;
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: Obx(() {
              final notes = controller.filteredNotes;

              if (notes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No academic resources found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Be the first to upload lecture handouts, assignments, or study guides.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final NoteModel note = notes[index];
                  final bool isUploader = note.uploadedBy == currentUid;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade100, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  note.subject,
                                  style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              if (isUploader || isAdmin)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    Get.defaultDialog(
                                      title: 'Delete Note',
                                      middleText:
                                          'Are you sure you want to remove this note?',
                                      textConfirm: 'Delete',
                                      textCancel: 'Cancel',
                                      confirmTextColor: Colors.white,
                                      buttonColor: Colors.red,
                                      onConfirm: () {
                                        Get.back();
                                        controller.deleteNote(note.id);
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            note.description,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 14,
                            ),
                          ),
                          if (!isUploader) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                label: const Text('Chat with Student'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue.shade800,
                                  side: BorderSide(color: Colors.blue.shade400),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Get.toNamed(
                                    AppRoutes.chat,
                                    arguments: {
                                      'otherUserId': note.uploadedBy,
                                      'otherUserName': 'Student (Note Contributor)',
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadNoteSheet(context, controller),
        icon: const Icon(Icons.upload_file),
        label: const Text('Share Notes'),
      ),
    );
  }
}

// Dedicated StatefulWidget for Upload Note Bottom Sheet
class _UploadNoteBottomSheet extends StatefulWidget {
  final NotesController controller;

  const _UploadNoteBottomSheet({required this.controller});

  @override
  State<_UploadNoteBottomSheet> createState() => _UploadNoteBottomSheetState();
}

class _UploadNoteBottomSheetState extends State<_UploadNoteBottomSheet> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  String selectedSubject = 'Computer Science';

  final List<String> subjects = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Electronics',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Academic Notes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Note Title (e.g. Unit 3 Trees & Graphs Notes)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject / Course',
                border: OutlineInputBorder(),
              ),
              items: subjects
                  .map((subj) => DropdownMenuItem(
                        value: subj,
                        child: Text(subj),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedSubject = value);
                }
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description / Key Topics Covered',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.controller.isLoading.value
                      ? null
                      : () {
                          widget.controller.uploadNote(
                            title: titleController.text,
                            subject: selectedSubject,
                            description: descriptionController.text,
                          );
                        },
                  child: widget.controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Share Notes',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

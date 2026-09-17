import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/lost_found_controller.dart';
import '../models/lost_found_model.dart';

class LostFoundView extends StatelessWidget {
  const LostFoundView({super.key});

  void _showAddReportSheet(BuildContext context, LostFoundController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddReportBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LostFoundController());
    final AuthController authController = Get.find<AuthController>();
    final String currentUid = authController.userModel.value?.uid ?? '';
    final bool isAdmin = authController.userModel.value?.role == 'Admin';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Obx(
              () => Row(
                children: ['All', 'Lost', 'Found'].map((filter) {
                  final isSelected = controller.selectedFilter.value == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: theme.primaryColor.withAlpha(40),
                      labelStyle: TextStyle(
                        color: isSelected ? theme.primaryColor : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectedFilter.value = filter;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Items List
          Expanded(
            child: Obx(() {
              final items = controller.filteredItems;

              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.layers_clear_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No active reports found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Be the first to report a lost or found item on campus.',
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
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final LostFoundModel item = items[index];
                  final bool isOwner = item.reportedBy == currentUid;
                  final bool isLost = item.type == 'Lost';
                  final bool isResolved = item.status == 'Resolved';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: isResolved ? Colors.grey.shade50 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isResolved ? Colors.grey.shade200 : Colors.grey.shade100, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isLost ? Colors.red.shade50 : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.type.toUpperCase(),
                                      style: TextStyle(
                                        color: isLost ? Colors.red.shade800 : Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isResolved ? Colors.grey.shade200 : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(),
                                      style: TextStyle(
                                        color: isResolved ? Colors.grey.shade700 : Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isOwner || isAdmin)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isResolved ? Icons.check_circle : Icons.check_circle_outline,
                                        color: isResolved ? Colors.grey : Colors.blue.shade700,
                                      ),
                                      tooltip: 'Mark as Resolved/Active',
                                      onPressed: () => controller.toggleReportStatus(item.id, item.status),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: 'Delete Report',
                                          middleText: 'Are you sure you want to delete this report?',
                                          textConfirm: 'Delete',
                                          textCancel: 'Cancel',
                                          confirmTextColor: Colors.white,
                                          buttonColor: Colors.red,
                                          onConfirm: () {
                                            Get.back();
                                            controller.deleteReport(item.id);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              decoration: isResolved ? TextDecoration.lineThrough : null,
                              color: isResolved ? Colors.grey : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                item.location,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.description,
                            style: TextStyle(fontSize: 14, color: isResolved ? Colors.grey : Colors.black87),
                          ),
                          if (!isOwner && !isResolved) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                label: Text(isLost ? 'Chat with Owner' : 'Contact Finder'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isLost ? Colors.red.shade800 : Colors.green.shade800,
                                  side: BorderSide(color: isLost ? Colors.red.shade300 : Colors.green.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Get.toNamed(
                                    AppRoutes.chat,
                                    arguments: {
                                      'otherUserId': item.reportedBy,
                                      'otherUserName': isLost ? 'Item Owner' : 'Item Finder',
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
        onPressed: () => _showAddReportSheet(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Report Item'),
      ),
    );
  }
}

// Dedicated StatefulWidget for Add Report Bottom Sheet to maintain controller lifecycle and text focus
class _AddReportBottomSheet extends StatefulWidget {
  final LostFoundController controller;

  const _AddReportBottomSheet({required this.controller});

  @override
  State<_AddReportBottomSheet> createState() => _AddReportBottomSheetState();
}

class _AddReportBottomSheetState extends State<_AddReportBottomSheet> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController locationController;
  String reportType = 'Lost';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    locationController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
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
              'Report Lost / Found Item',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('I Lost Something')),
                    selected: reportType == 'Lost',
                    selectedColor: Colors.red.shade100,
                    onSelected: (selected) {
                      if (selected) setState(() => reportType = 'Lost');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('I Found Something')),
                    selected: reportType == 'Found',
                    selectedColor: Colors.green.shade100,
                    onSelected: (selected) {
                      if (selected) setState(() => reportType = 'Found');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Item Title (e.g. Blue Water Bottle)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location (e.g. Library 2nd Floor)',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description / Details',
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
                          widget.controller.createReport(
                            title: titleController.text,
                            description: descriptionController.text,
                            location: locationController.text,
                            type: reportType,
                          );
                        },
                  child: widget.controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Report',
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

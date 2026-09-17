import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../controllers/complaints_controller.dart';
import '../models/complaint_model.dart';

class ComplaintsView extends StatelessWidget {
  const ComplaintsView({super.key});

  void _showSubmitComplaintSheet(
      BuildContext context, ComplaintsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SubmitComplaintBottomSheet(controller: controller),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Reported':
        return Colors.amber.shade700;
      case 'Assigned':
        return Colors.blue.shade700;
      case 'In Progress':
        return Colors.indigo.shade700;
      case 'Resolved':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  int _getStatusStepIndex(String status) {
    switch (status) {
      case 'Reported':
        return 0;
      case 'Assigned':
        return 1;
      case 'In Progress':
        return 2;
      case 'Resolved':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplaintsController());
    final AuthController authController = Get.find<AuthController>();
    final String currentUid = authController.userModel.value?.uid ?? '';
    final bool isAdmin = authController.userModel.value?.role == 'Admin';
    final theme = Theme.of(context);

    final filters = ['All', 'My Complaints', 'Reported', 'In Progress', 'Resolved'];
    final statusOptions = ['Reported', 'Assigned', 'In Progress', 'Resolved'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Complaints', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters.map((filter) {
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
          ),

          // Complaints List
          Expanded(
            child: Obx(() {
              final complaints = controller.filteredComplaints;

              if (complaints.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No grievances found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Everything is running smoothly or choose a different dashboard filter.',
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
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final ComplaintModel complaint = complaints[index];
                  final bool isReporter = complaint.reportedBy == currentUid;
                  final Color statusColor = _getStatusColor(complaint.status);
                  final int stepIndex = _getStatusStepIndex(complaint.status);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
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
                          // Card Header: Status Badge + Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  complaint.status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  // Admin Status Update Dropdown Menu
                                  if (isAdmin)
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.edit_calendar_outlined,
                                          color: theme.primaryColor),
                                      tooltip: 'Update Status',
                                      onSelected: (newStatus) {
                                        controller.updateComplaintStatus(
                                            complaint.id, newStatus);
                                      },
                                      itemBuilder: (context) => statusOptions
                                          .map(
                                            (st) => PopupMenuItem(
                                              value: st,
                                              child: Text('Mark as $st'),
                                            ),
                                          )
                                          .toList(),
                                    ),

                                  if (isReporter || isAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: 'Delete Complaint',
                                          middleText:
                                              'Are you sure you want to delete this complaint?',
                                          textConfirm: 'Delete',
                                          textCancel: 'Cancel',
                                          confirmTextColor: Colors.white,
                                          buttonColor: Colors.red,
                                          onConfirm: () {
                                            Get.back();
                                            controller.deleteComplaint(complaint.id);
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            complaint.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                complaint.location,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            complaint.description,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 12),

                          // Complaint Lifecycle Tracker Progress
                          Text(
                            'LIFECYCLE STATUS PROGRESS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              for (int i = 0; i < statusOptions.length; i++) ...[
                                Expanded(
                                  child: Column(
                                    children: [
                                      Icon(
                                        i <= stepIndex
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        size: 18,
                                        color: i <= stepIndex
                                            ? _getStatusColor(statusOptions[i])
                                            : Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        statusOptions[i],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: i == stepIndex
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: i <= stepIndex
                                              ? Colors.black87
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < statusOptions.length - 1)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Divider(
                                        color: i < stepIndex
                                            ? _getStatusColor(statusOptions[i + 1])
                                            : Colors.grey.shade200,
                                        thickness: 2,
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
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
        onPressed: () => _showSubmitComplaintSheet(context, controller),
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Submit Complaint'),
      ),
    );
  }
}

// Dedicated StatefulWidget for Submit Complaint Bottom Sheet
class _SubmitComplaintBottomSheet extends StatefulWidget {
  final ComplaintsController controller;

  const _SubmitComplaintBottomSheet({required this.controller});

  @override
  State<_SubmitComplaintBottomSheet> createState() =>
      _SubmitComplaintBottomSheetState();
}

class _SubmitComplaintBottomSheetState
    extends State<_SubmitComplaintBottomSheet> {
  late final TextEditingController titleController;
  late final TextEditingController locationController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    locationController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
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
              'Submit Campus Complaint',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Complaint Title (e.g. Broken AC in Lab 4)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location / Room Number (e.g. Block C, Room 301)',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description / Problem Details',
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
                          widget.controller.createComplaint(
                            title: titleController.text,
                            location: locationController.text,
                            description: descriptionController.text,
                          );
                        },
                  child: widget.controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Complaint',
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/admin_controller.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    final shortcuts = [
      ('Lost & Found', Icons.search, AppRoutes.lostFound, Colors.orange),
      ('Marketplace', Icons.storefront, AppRoutes.marketplace, Colors.green),
      ('Campus Events', Icons.event, AppRoutes.events, Colors.purple),
      ('Complaints', Icons.build, AppRoutes.complaints, Colors.red),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Banner Header
            Card(
              color: Colors.indigo.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.admin_panel_settings,
                          size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Campus Control Center',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              'Total Registered Users: ${controller.userList.length}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Content Moderation Shortcuts
            const Text(
              'Moderation & Content Shortcuts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: shortcuts.length,
              itemBuilder: (context, index) {
                final item = shortcuts[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => Get.toNamed(item.$3),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: item.$4.withAlpha(30),
                            child: Icon(item.$2, color: item.$4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.$1,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // User Management Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => Chip(
                    label: Text('${controller.filteredUsers.length} Users'),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar for Users
            TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
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

            // Users List
            Obx(() {
              final users = controller.filteredUsers;

              if (users.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text(
                      'No registered users found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final UserModel user = users[index];
                  final bool isAdminUser = user.role == 'Admin';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isAdminUser ? Colors.purple : Colors.blue,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              user.role,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            backgroundColor:
                                isAdminUser ? Colors.purple : Colors.blue,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.indigo, size: 20),
                            tooltip: 'Chat with Student',
                            onPressed: () {
                              Get.toNamed(
                                AppRoutes.chat,
                                arguments: {
                                  'otherUserId': user.uid,
                                  'otherUserName': user.name,
                                },
                              );
                            },
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            tooltip: 'Change Role',
                            onSelected: (newRole) {
                              Get.defaultDialog(
                                title: 'Change Role',
                                middleText:
                                    'Change ${user.name}\'s role to $newRole?',
                                textConfirm: 'Confirm',
                                textCancel: 'Cancel',
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.indigo,
                                onConfirm: () {
                                  Get.back();
                                  controller.updateUserRole(user.uid, newRole);
                                },
                              );
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Student',
                                child: Text('Make Student'),
                              ),
                              const PopupMenuItem(
                                value: 'Admin',
                                child: Text('Make Admin'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

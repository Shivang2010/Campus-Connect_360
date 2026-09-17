import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _showProfileDialog(BuildContext context, AuthController authController) {
    final user = authController.userModel.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(user?.name ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(user?.email ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Role'),
              subtitle: Text(user?.role ?? 'Student'),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('View All Conversations'),
                  onPressed: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.chats);
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final HomeController homeController = Get.put(HomeController());

    final features = [
      ('Lost & Found', Icons.search, AppRoutes.lostFound, Colors.orange),
      ('Events', Icons.event, AppRoutes.events, Colors.purple),
      ('Marketplace', Icons.storefront, AppRoutes.marketplace, Colors.green),
      ('Notes', Icons.menu_book, AppRoutes.notes, Colors.blue),
      ('Complaints', Icons.build, AppRoutes.complaints, Colors.red),
      ('Messages', Icons.chat, AppRoutes.chats, Colors.teal),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusConnect 360'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Messages',
            onPressed: () => Get.toNamed(AppRoutes.chats),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () => _showProfileDialog(context, authController),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authController.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Obx(() {
              final user = authController.userModel.value;
              final String name = user?.name ?? 'Student';
              final String role = user?.role ?? 'Student';
              final bool isAdmin = role == 'Admin';

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isAdmin ? Colors.purple : Colors.blue,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, $name!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                role,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor:
                                  isAdmin ? Colors.purple : Colors.blue,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Live Weather Card (Dio REST API)
            Obx(() {
              if (homeController.isLoadingWeather.value) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Fetching campus weather...'),
                      ],
                    ),
                  ),
                );
              }

              if (homeController.weatherError.value.isNotEmpty) {
                return Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          homeController.weatherError.value,
                          style: TextStyle(color: Colors.orange.shade900),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => homeController.fetchWeather(),
                        )
                      ],
                    ),
                  ),
                );
              }

              final weather = homeController.weather.value;
              if (weather == null) return const SizedBox.shrink();

              return Card(
                elevation: 2,
                color: Colors.lightBlue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.lightBlue.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        weather.label.split(' ').first,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${weather.temperature.toStringAsFixed(1)}°C — ${weather.label.replaceFirst(RegExp(r'^[^ ]+ '), '')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Campus Weather • Wind: ${weather.windspeed} km/h',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        tooltip: 'Refresh weather',
                        onPressed: () => homeController.fetchWeather(),
                      )
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            const Text(
              'Campus Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Features Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final item = features[index];
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
                            backgroundColor: item.$4.withAlpha(40),
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

            const SizedBox(height: 16),

            // Admin Panel Shortcut (Only visible if User role is Admin)
            Obx(() {
              final user = authController.userModel.value;
              if (user?.role == 'Admin') {
                return Card(
                  color: Colors.indigo.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.indigo.shade200),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: Colors.indigo, size: 32),
                    title: const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    subtitle: const Text('Manage campus features & users'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.indigo),
                    onTap: () => Get.toNamed(AppRoutes.admin),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/controllers/auth_controller.dart';
import 'app/services/api_service.dart';
import 'app/services/chat_service.dart';
import 'app/services/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Global services — available anywhere via Get.find()
  Get.put(AuthController(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(ApiService(), permanent: true);
  Get.put(ChatService(), permanent: true);

  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CampusConnect 360',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}

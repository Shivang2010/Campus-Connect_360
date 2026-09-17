import 'package:get/get.dart';

import 'app_routes.dart';

import '../modules/home/views/home_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/lost_found/views/lost_found_view.dart';
import '../modules/events/views/events_view.dart';
import '../modules/marketplace/views/marketplace_view.dart';
import '../modules/notes/views/notes_view.dart';
import '../modules/complaints/views/complaints_view.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/chat/views/chat_list_view.dart';
import '../modules/chat/views/chat_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),

    GetPage(
      name: AppRoutes.lostFound,
      page: () => const LostFoundView(),
    ),

    GetPage(
      name: AppRoutes.events,
      page: () => const EventsView(),
    ),

    GetPage(
      name: AppRoutes.marketplace,
      page: () => const MarketplaceView(),
    ),

    GetPage(
      name: AppRoutes.notes,
      page: () => const NotesView(),
    ),

    GetPage(
      name: AppRoutes.complaints,
      page: () => const ComplaintsView(),
    ),

    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminView(),
    ),

    GetPage(
      name: AppRoutes.chats,
      page: () => const ChatListView(),
    ),

    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
    ),
  ];
}
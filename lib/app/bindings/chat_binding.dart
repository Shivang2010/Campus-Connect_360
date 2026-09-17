import 'package:get/get.dart';
import '../modules/chat/controllers/chat_controller.dart';

/// Binding for Chat routes ensuring ChatController is instantiated on navigation.
class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}

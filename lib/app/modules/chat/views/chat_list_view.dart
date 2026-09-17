import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_model.dart';

/// Screen displaying all active 1-to-1 conversations of the logged-in user.
class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages & Chats'),
        elevation: 1,
      ),
      body: Obx(() {
        if (chatController.isLoadingChats.value &&
            chatController.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatController.chats.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 72,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting by tapping "Chat with Seller" in Marketplace, "Chat with Owner" in Lost & Found, or in Notes!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            chatController.initChatList();
          },
          child: ListView.separated(
            itemCount: chatController.chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ChatModel chat = chatController.chats[index];
              final otherUid = chat.getOtherUserId(chatController.currentUserId);
              final otherName =
                  chat.getOtherUserName(chatController.currentUserId);

              // Format message timestamp
              String formattedTime = '';
              if (chat.lastMessageTime != null) {
                final now = DateTime.now();
                final diff = now.difference(chat.lastMessageTime!);
                if (diff.inDays == 0) {
                  formattedTime =
                      DateFormat.jm().format(chat.lastMessageTime!);
                } else if (diff.inDays == 1) {
                  formattedTime = 'Yesterday';
                } else {
                  formattedTime =
                      DateFormat.MMMd().format(chat.lastMessageTime!);
                }
              }

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade600,
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text(
                  otherName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  chat.lastMessage.isNotEmpty
                      ? chat.lastMessage
                      : 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                trailing: Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                onTap: () {
                  Get.toNamed(
                    AppRoutes.chat,
                    arguments: {
                      'otherUserId': otherUid,
                      'otherUserName': otherName,
                    },
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}

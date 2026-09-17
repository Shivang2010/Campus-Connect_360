import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';
import '../models/message_model.dart';

/// Screen displaying a real-time 1-to-1 chat room with message bubbles and send input.
class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final ChatController _controller;
  late final String otherUserId;
  late final String otherUserName;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());

    // Retrieve arguments passed via Get.toNamed
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    otherUserId = args['otherUserId'] ?? '';
    otherUserName = args['otherUserName'] ?? 'Student';

    if (otherUserId.isEmpty) {
      // Nothing to open — go back immediately
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
      return;
    }

    // Always (re-)initialise the chat room so that navigating here from
    // Lost & Found / Marketplace / Notes always loads the correct conversation,
    // even if ChatController is already registered from the Messages inbox.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initChatRoom(
        otherUserId: otherUserId,
        otherUserName: otherUserName,
      );
    });
  }

  @override
  void dispose() {
    // Clean up the active room's stream and state when leaving this screen.
    // This ensures the next chat opened (from any module) starts fresh.
    _controller.closeRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(() {
          final resolvedName = _controller.activeOtherUserName.value;
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  resolvedName.isNotEmpty ? resolvedName[0].toUpperCase() : 'S',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolvedName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Campus Student',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Messages List ─────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (_controller.isLoadingMessages.value &&
                    _controller.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.waving_hand_outlined,
                            size: 48,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Say hello to ${_controller.activeOtherUserName.value}!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Send a message to start discussing notes, items, or campus updates.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _controller.scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  itemCount: _controller.messages.length,
                  itemBuilder: (context, index) {
                    final MessageModel msg = _controller.messages[index];
                    final bool isMe =
                        msg.senderId == _controller.currentUserId;

                    return _buildMessageBubble(
                      context: context,
                      message: msg,
                      isMe: isMe,
                    );
                  },
                );
              }),
            ),

            // ── Bottom Message Input Bar ──────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller.textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onSubmitted: (_) => _controller.sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    return CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.primaryColor,
                      child: IconButton(
                        icon: _controller.isSending.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                        onPressed: _controller.isSending.value
                            ? null
                            : () => _controller.sendMessage(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required BuildContext context,
    required MessageModel message,
    required bool isMe,
  }) {
    final theme = Theme.of(context);
    final timeStr = DateFormat.jm().format(message.createdAt);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? theme.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(3),
            bottomRight: isMe ? const Radius.circular(3) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.lightBlueAccent : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

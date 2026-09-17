import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/chat_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

/// GetX controller managing UI state for the Chat List and active Chat Room screens.
class ChatController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  final AuthController _authController = Get.find<AuthController>();

  // ── Observables ───────────────────────────────────────────────
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoadingChats = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;

  // Active chat metadata
  final RxString currentChatId = ''.obs;
  final RxString activeOtherUserId = ''.obs;
  final RxString activeOtherUserName = ''.obs;

  // Stream Subscriptions
  StreamSubscription<List<ChatModel>>? _chatsSubscription;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  // Controllers for the ChatView
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String get currentUserId => _authController.firebaseUser.value?.uid ?? '';
  String get currentUserName =>
      _authController.userModel.value?.name ?? 'Student';

  @override
  void onInit() {
    super.onInit();
    initChatList();
  }

  @override
  void onClose() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────
  // 1. Initialize Chat List (All user conversations)
  // ─────────────────────────────────────────────────────────────

  void initChatList() {
    if (currentUserId.isEmpty) return;

    isLoadingChats.value = true;
    _chatsSubscription?.cancel();

    _chatsSubscription =
        _chatService.streamUserChats(currentUserId).listen((chatList) {
      chats.assignAll(chatList);
      isLoadingChats.value = false;
    }, onError: (err) {
      isLoadingChats.value = false;
      debugPrint('[ChatController] Error loading chats: $err');
    });
  }

  // ─────────────────────────────────────────────────────────────
  // 2. Open / Initialize a Specific Chat Room
  // ─────────────────────────────────────────────────────────────

  Future<bool> initChatRoom({
    required String otherUserId,
    required String otherUserName,
  }) async {
    // 🛡️ Guard against user chatting with themselves
    if (currentUserId == otherUserId) {
      Get.snackbar(
        'Action Not Allowed',
        'You cannot chat with yourself.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    // ── Reset previous room state immediately so the UI shows a clean slate ──
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    messages.clear();
    currentChatId.value = '';
    activeOtherUserId.value = otherUserId;
    activeOtherUserName.value = otherUserName;

    try {
      isLoadingMessages.value = true;

      // Lazy-load the real name from Firestore to replace placeholders
      FirebaseFirestore.instance.collection('users').doc(otherUserId).get().then((doc) {
        if (doc.exists && doc.data()?['name'] != null) {
          activeOtherUserName.value = doc.data()?['name'];
        }
      });

      // 1. Get or create the chat document (also patches placeholder names)
      final chatId = await _chatService.getOrCreateChat(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
      );

      currentChatId.value = chatId;

      // 2. Listen to real-time messages
      _messagesSubscription =
          _chatService.streamMessages(chatId).listen((msgList) {
        messages.assignAll(msgList);
        isLoadingMessages.value = false;

        // Auto-mark unread messages as read
        _chatService.markMessagesAsRead(
          chatId: chatId,
          currentUserId: currentUserId,
        );

        // Auto-scroll to bottom on new message
        _scrollToBottom();
      }, onError: (err) {
        isLoadingMessages.value = false;
        debugPrint('[ChatController] Error streaming messages: $err');
      });

      return true;
    } catch (e) {
      isLoadingMessages.value = false;
      Get.snackbar('Chat Error', 'Unable to load chat: $e');
      return false;
    }
  }

  /// Call this when leaving the chat room screen to clean up subscriptions and state.
  void closeRoom() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    messages.clear();
    currentChatId.value = '';
    activeOtherUserId.value = '';
    activeOtherUserName.value = '';
    textController.clear();
  }

  // ─────────────────────────────────────────────────────────────
  // 3. Send Message
  // ─────────────────────────────────────────────────────────────

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || currentChatId.value.isEmpty || isSending.value) return;

    try {
      isSending.value = true;
      textController.clear();

      await _chatService.sendMessage(
        chatId: currentChatId.value,
        senderId: currentUserId,
        receiverId: activeOtherUserId.value,
        messageText: text,
      );

      _scrollToBottom();
    } catch (e) {
      Get.snackbar('Send Failed', 'Could not send message: $e');
    } finally {
      isSending.value = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../models/booking_document.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // ── Args dari navigation ──────────────────────────────────────
  late final String chatId;
  late final String otherPartyName;
  String? otherPartyPhotoUrl;

  // ── State ─────────────────────────────────────────────────────
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;

  // ── Current user ──────────────────────────────────────────────
  String get currentUserId => _authService.currentUser?.uid ?? '';
  String _currentUserName = '';

  final TextEditingController inputController = TextEditingController();
  StreamSubscription? _msgSub;

  @override
  void onInit() {
    super.onInit();
    _loadFromArgs();
    _initStream();
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    inputController.dispose();
    super.onClose();
  }

  void _loadFromArgs() {
    final args = Get.arguments;
    if (args is Map) {
      chatId = args['chatId'] as String? ?? '';
      otherPartyName = args['otherPartyName'] as String? ?? 'Pengguna';
      otherPartyPhotoUrl = args['otherPartyPhotoUrl'] as String?;

      // Ensure chat doc exists (fire & forget)
      final bookingDoc = args['bookingDoc'] as BookingDocument?;
      if (bookingDoc != null) {
        _chatService.ensureChatExists(
          chatId: chatId,
          bookingId: bookingDoc.bookingId,
          customerId: bookingDoc.userId,
          customerName: bookingDoc.userName,
          technicianId: bookingDoc.technicianId,
          technicianName: bookingDoc.technicianName,
          technicianPhotoUrl: bookingDoc.technicianPhotoUrl,
        );
      }
    } else {
      chatId = '';
      otherPartyName = 'Pengguna';
    }
  }

  Future<void> _initStream() async {
    // Dapatkan nama user sekarang
    final uid = currentUserId;
    if (uid.isNotEmpty) {
      final user = await _authService.getUserModel(uid);
      _currentUserName =
          user?.name ?? _authService.currentUser?.email ?? 'Saya';
    }

    if (chatId.isEmpty) {
      isLoading.value = false;
      return;
    }

    _msgSub = _chatService.streamMessages(chatId).listen(
      (msgs) {
        messages.assignAll(msgs);
        isLoading.value = false;
        // Mark incoming as read
        _chatService.markAsRead(chatId, currentUserId);
      },
      onError: (e) {
        debugPrint('ChatController stream error: $e');
        isLoading.value = false;
      },
    );
  }

  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty || chatId.isEmpty) return;

    inputController.clear();
    isSending.value = true;

    try {
      await _chatService.sendMessage(
        chatId: chatId,
        senderId: currentUserId,
        senderName: _currentUserName,
        text: text,
      );
    } catch (e) {
      debugPrint('sendMessage error: $e');
      Get.snackbar('Gagal', 'Pesan tidak terkirim',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSending.value = false;
    }
  }

  bool isMine(ChatMessage msg) => msg.senderId == currentUserId;
}

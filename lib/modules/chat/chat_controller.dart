import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/chat_service.dart';
import '../../models/booking_document.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();

  // ── Args dari navigation ──────────────────────────────────────
  late final String chatId;
  late final String otherPartyName;
  String? otherPartyPhotoUrl;

  // ── State ─────────────────────────────────────────────────────
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;

  /// true jika booking sudah done/cancelled — input dinonaktifkan.
  final RxBool sessionClosed = false.obs;

  // ── Current user ──────────────────────────────────────────────
  String get currentUserId => _authService.currentUser?.uid ?? '';
  String _currentUserName = '';

  final TextEditingController inputController = TextEditingController();
  StreamSubscription? _msgSub;
  StreamSubscription? _bookingSub;
  String? _bookingId; // non-null hanya untuk booking-attached chat

  @override
  void onInit() {
    super.onInit();
    _loadFromArgs();
    _initStream();
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    _bookingSub?.cancel();
    inputController.dispose();
    super.onClose();
  }

  void _loadFromArgs() {
    final args = Get.arguments;
    if (args is Map) {
      otherPartyName = args['otherPartyName'] as String? ?? 'Pengguna';
      otherPartyPhotoUrl = args['otherPartyPhotoUrl'] as String?;

      final bookingDoc = args['bookingDoc'] as BookingDocument?;

      // ── Case 1: chat dari tracking/active job (ada bookingDoc) ──
      if (bookingDoc != null) {
        chatId = bookingDoc.bookingId;
        _bookingId = bookingDoc.bookingId;
        // Jika booking sudah done/cancelled saat dibuka, langsung tutup
        if (bookingDoc.status == BookingStatus.done ||
            bookingDoc.status == BookingStatus.cancelled) {
          sessionClosed.value = true;
        }
        _chatService.ensureChatExists(
          chatId: chatId,
          bookingId: bookingDoc.bookingId,
          customerId: bookingDoc.userId,
          customerName: bookingDoc.userName,
          technicianId: bookingDoc.technicianId,
          technicianName: bookingDoc.technicianName,
          technicianPhotoUrl: bookingDoc.technicianPhotoUrl,
        );
        return;
      }

      // ── Case 2: pre-booking chat dari technician detail ──────────
      final customerId   = args['customerId']   as String?;
      final customerName = args['customerName'] as String?;
      final techId       = args['technicianId'] as String?;

      if (customerId != null && techId != null) {
        chatId = ChatService.preChatId(customerId, techId);
        _chatService.ensurePreChatExists(
          customerId: customerId,
          customerName: customerName ?? 'Customer',
          technicianId: techId,
          technicianName: otherPartyName,
          technicianPhotoUrl: otherPartyPhotoUrl,
        );
        return;
      }

      // ── Case 3: fallback — chatId eksplisit dikirim (misal dari inbox) ──
      chatId = args['chatId'] as String? ?? '';
      // bookingId opsional — dipakai untuk stream status saat dibuka dari inbox
      _bookingId = args['bookingId'] as String?;
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

    // Stream status booking agar chat otomatis tertutup saat done/cancelled
    if (_bookingId != null) {
      _bookingSub = _bookingService.streamBookingById(_bookingId!).listen(
        (doc) {
          if (doc != null &&
              (doc.status == BookingStatus.done ||
                  doc.status == BookingStatus.cancelled)) {
            sessionClosed.value = true;
            _bookingSub?.cancel();
          }
        },
        onError: (e) => debugPrint('ChatController booking stream error: $e'),
      );
    }
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

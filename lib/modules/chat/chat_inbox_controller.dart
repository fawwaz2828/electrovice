import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';

class ChatInboxController extends GetxController {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  final RxList<ChatRoomData> chatRooms = <ChatRoomData>[].obs;
  final RxBool isLoading = true.obs;

  String get currentUserId => _authService.currentUser?.uid ?? '';

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _initStream();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> _initStream() async {
    int retry = 0;
    while (_authService.currentUser == null && retry < 6) {
      await Future.delayed(const Duration(milliseconds: 500));
      retry++;
    }
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }
    _sub = _chatService.streamUserChats(uid).listen(
      (rooms) {
        chatRooms.assignAll(rooms);
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('ChatInboxController error: $e');
        isLoading.value = false;
      },
    );
  }
}

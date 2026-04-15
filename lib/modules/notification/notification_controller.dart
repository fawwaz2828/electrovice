import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../models/notification_model.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class NotificationController extends GetxController {
  final _authService = AuthService();
  final _notifService = NotificationService();

  final RxInt unreadCount = 0.obs;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription? _countSub;
  StreamSubscription? _listSub;
  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    _countSub?.cancel();
    _listSub?.cancel();
    super.onClose();
  }

  Future<void> _init() async {
    int retry = 0;
    while (_authService.currentUser == null && retry < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      retry++;
    }
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    _userId = uid;

    _countSub = _notifService.streamUnreadCount(uid).listen(
      (count) => unreadCount.value = count,
      onError: (e) => debugPrint('NotificationController count error: $e'),
    );

    _listSub = _notifService.streamAll(uid).listen(
      (list) {
        notifications.assignAll(list);
        isLoading.value = false;
      },
      onError: (e) {
        debugPrint('NotificationController list error: $e');
        isLoading.value = false;
      },
    );
  }

  Future<void> markAsRead(String itemId) async {
    if (_userId == null) return;
    await _notifService.markAsRead(_userId!, itemId);
  }

  Future<void> markAllRead() async {
    if (_userId == null) return;
    await _notifService.markAllRead(_userId!);
  }
}

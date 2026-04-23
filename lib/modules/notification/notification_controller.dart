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

  /// Role user yang sedang login — dipakai untuk routing & filtering
  String userRole = 'customer';

  StreamSubscription? _countSub;
  StreamSubscription? _listSub;
  String? _userId;

  // Tipe notif yang relevan per role
  static const _technicianTypes = {
    NotifType.newOrder,
    NotifType.orderCancelled,
    NotifType.paymentConfirmed,
    NotifType.chat,
  };
  static const _customerTypes = {
    NotifType.orderAccepted,
    NotifType.orderDeclined,
    NotifType.onProgress,
    NotifType.awaitingPayment,
    NotifType.chat,
  };

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

    // Ambil role user sekali saja
    userRole = await _authService.getUserRole(uid) ?? 'customer';

    final relevantTypes = userRole == 'technician'
        ? _technicianTypes
        : _customerTypes;

    _countSub = _notifService.streamUnreadCount(uid).listen(
      (count) {
        // Hitung ulang hanya dari notif yang relevan
        final unread = notifications
            .where((n) => !n.isRead && relevantTypes.contains(n.type))
            .length;
        unreadCount.value = unread;
      },
      onError: (e) => debugPrint('NotificationController count error: $e'),
    );

    _listSub = _notifService.streamAll(uid).listen(
      (list) {
        // Filter: hanya tampilkan notif yang sesuai role
        final filtered = list
            .where((n) => relevantTypes.contains(n.type))
            .toList();
        notifications.assignAll(filtered);
        // Sync unread count
        unreadCount.value = filtered.where((n) => !n.isRead).length;
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

  Future<void> clearAll() async {
    if (_userId == null) return;
    await _notifService.clearAll(_userId!);
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/routes.dart';
import 'auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background handler — HARUS top-level function (bukan method/closure)
// Dipanggil oleh sistem saat notif masuk dan app di-terminate/background.
// Cukup untuk memproses data; navigasi tidak bisa dilakukan di sini.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase sudah di-init di main() sebelum handler ini dipasang.
  // Tidak perlu init ulang.
}

// ─────────────────────────────────────────────────────────────────────────────
// FCM Handler — setup listener & logika navigasi
// ─────────────────────────────────────────────────────────────────────────────
class FcmHandler {
  FcmHandler._();

  /// Dipanggil sekali di main() setelah Firebase.initializeApp()
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Minta izin notifikasi (Android 13+ & iOS)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Pastikan notif Android foreground tampil sebagai heads-up
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── 1. App TERMINATED → user tap notif → app buka ────────────
    // Simpan dulu, navigasi setelah runApp & GetX navigator siap.
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      // WidgetsBinding.addPostFrameCallback tidak tersedia di sini (pre-runApp),
      // pakai Future.delayed lebih panjang agar route pertama sudah ter-render.
      Future.delayed(const Duration(seconds: 2), () {
        _navigate(initialMessage.data);
      });
    }

    // ── 2. App BACKGROUND → user tap notif ───────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigate(message.data);
    });

    // ── 3. App FOREGROUND → notif masuk ──────────────────────────
    // Sistem Android tidak otomatis tampilkan heads-up saat foreground,
    // jadi kita tampilkan sendiri sebagai snackbar di atas.
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      if (title.isEmpty && body.isEmpty) return;

      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        isDismissible: true,
        onTap: (_) => _navigate(message.data),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // Navigasi berdasarkan type + bookingId dari data payload FCM
  // ─────────────────────────────────────────────────────────────────
  static Future<void> _navigate(Map<String, dynamic> data) async {
    final type = data['type'] as String? ?? '';
    final bookingId = data['bookingId'] as String? ?? '';

    // Pastikan user sudah login sebelum navigasi
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;

    switch (type) {
      // ── Teknisi: ada booking baru masuk ────────────────────────
      // jobDetail butuh selectedOrder di TechnicianController — tidak bisa
      // di-set dari sini. Arahkan ke activeOrders supaya teknisi pilih sendiri.
      case 'new_order':
        Get.toNamed(AppRoutes.activeOrders);
        break;

      // ── Customer: teknisi accept order ─────────────────────────
      case 'order_accepted':
      // ── Customer: teknisi sudah tiba & mulai kerja ─────────────
      case 'on_progress':
        Get.toNamed(AppRoutes.orderTracking);
        break;

      // ── Customer: tagihan siap dibayar ─────────────────────────
      case 'awaiting_payment':
        if (bookingId.isEmpty) {
          Get.toNamed(AppRoutes.customerOrders);
        } else {
          Get.toNamed(AppRoutes.bookingDetail, arguments: bookingId);
        }
        break;

      // ── Teknisi: pembayaran diterima ────────────────────────────
      case 'payment_confirmed':
        Get.toNamed(AppRoutes.technicianOrderHistory);
        break;

      // ── Customer: teknisi menolak order ───────────────────────
      case 'order_declined':
        Get.toNamed(AppRoutes.customerOrders);
        break;

      // ── Kedua pihak: order dibatalkan ──────────────────────────
      case 'order_cancelled':
        // Cek role dari Firestore untuk arahkan ke halaman yang benar
        final role = await AuthService().getUserRole(uid);
        if (role == 'technician') {
          Get.toNamed(AppRoutes.activeOrders);
        } else {
          Get.toNamed(AppRoutes.customerOrders);
        }
        break;

      // ── Chat: pesan baru masuk ─────────────────────────────────
      case 'chat':
        final chatId = data['chatId'] as String? ?? '';
        if (chatId.isNotEmpty) {
          Get.toNamed(AppRoutes.chat, arguments: {'chatId': chatId});
        } else {
          Get.toNamed(AppRoutes.chatInbox);
        }
        break;

      default:
        // Type tidak dikenal — tidak navigasi
        break;
    }
  }
}

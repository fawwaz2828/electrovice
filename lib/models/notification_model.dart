import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? bookingId;
  final String? fromName;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.bookingId,
    this.fromName,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      type: d['type'] as String? ?? '',
      bookingId: d['bookingId'] as String?,
      fromName: d['fromName'] as String?,
      isRead: d['isRead'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ── Notification types ─────────────────────────────────────────────────────
abstract class NotifType {
  static const newOrder = 'new_order';           // teknisi: ada order masuk
  static const orderAccepted = 'order_accepted'; // customer: teknisi accept
  static const orderDeclined = 'order_declined'; // customer: teknisi decline
  static const orderCancelled = 'order_cancelled'; // teknisi: customer cancel
  static const onProgress = 'on_progress';       // customer: verifikasi berhasil
  static const awaitingPayment = 'awaiting_payment'; // customer: siap bayar
  static const paymentConfirmed = 'payment_confirmed'; // teknisi: bayar done
}

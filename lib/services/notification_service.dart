import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _items(String userId) => _db
      .collection('notifications')
      .doc(userId)
      .collection('items');

  // ── Send ───────────────────────────────────────────────────────
  Future<void> send({
    required String toUserId,
    required String title,
    required String body,
    required String type,
    String? bookingId,
    String? fromName,
  }) async {
    try {
      await _items(toUserId).add({
        'title': title,
        'body': body,
        'type': type,
        'bookingId': bookingId,
        'fromName': fromName,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService.send error: $e');
    }
  }

  // ── Stream unread count (untuk badge) ─────────────────────────
  Stream<int> streamUnreadCount(String userId) {
    return _items(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ── Stream all notifications ───────────────────────────────────
  Stream<List<NotificationItem>> streamAll(String userId) {
    return _items(userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map(NotificationItem.fromFirestore).toList());
  }

  // ── Mark single as read ────────────────────────────────────────
  Future<void> markAsRead(String userId, String itemId) async {
    await _items(userId).doc(itemId).update({'isRead': true});
  }

  // ── Mark all as read ───────────────────────────────────────────
  Future<void> markAllRead(String userId) async {
    final snap =
        await _items(userId).where('isRead', isEqualTo: false).get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Delete all notifications ────────────────────────────────────
  Future<void> clearAll(String userId) async {
    final snap = await _items(userId).get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

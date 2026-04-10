import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Ensure chat room exists ────────────────────────────────────
  /// Pastikan dokumen chat ada. Dipanggil sebelum membuka ChatPage.
  /// chatId = bookingId (1 booking = 1 chat room).
  Future<void> ensureChatExists({
    required String chatId,
    required String bookingId,
    required String customerId,
    required String customerName,
    required String technicianId,
    required String technicianName,
    String? customerPhotoUrl,
    String? technicianPhotoUrl,
  }) async {
    final ref = _db.collection('chats').doc(chatId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'bookingId': bookingId,
        'participants': [customerId, technicianId],
        'customerName': customerName,
        'technicianName': technicianName,
        'customerPhotoUrl': customerPhotoUrl,
        'technicianPhotoUrl': technicianPhotoUrl,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Send message ───────────────────────────────────────────────
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final batch = _db.batch();
    final msgRef =
        _db.collection('chats').doc(chatId).collection('messages').doc();

    batch.set(msgRef, {
      'senderId': senderId,
      'senderName': senderName,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Upsert metadata di parent doc (set+merge agar tidak gagal jika doc belum ada)
    batch.set(
      _db.collection('chats').doc(chatId),
      {
        'lastMessage': trimmed,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  // ── Stream messages ────────────────────────────────────────────
  Stream<List<ChatMessage>> streamMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromFirestore).toList());
  }

  // ── Mark as read ───────────────────────────────────────────────
  /// Filter senderId di client-side untuk menghindari composite index.
  Future<void> markAsRead(String chatId, String currentUserId) async {
    final snap = await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    final unreadFromOther = snap.docs
        .where((d) => (d['senderId'] as String?) != currentUserId)
        .toList();

    if (unreadFromOther.isEmpty) return;

    final batch = _db.batch();
    for (final doc in unreadFromOther) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}

// ── Model ──────────────────────────────────────────────────────────────────
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}

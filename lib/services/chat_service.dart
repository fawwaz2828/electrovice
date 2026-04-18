import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Ensure chat room exists ────────────────────────────────────
  /// Pastikan dokumen chat ada. Dipanggil sebelum membuka ChatPage.
  /// chatId = bookingId  ATAU  pre-booking chatId (lihat [preChatId]).
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
        'customerId': customerId,
        'technicianId': technicianId,
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
    } else {
      // Update foto jika sebelumnya tidak ada (migrasi chat room lama)
      final data = snap.data() ?? {};
      final updates = <String, dynamic>{};
      if (customerPhotoUrl != null &&
          customerPhotoUrl.isNotEmpty &&
          (data['customerPhotoUrl'] == null ||
              (data['customerPhotoUrl'] as String).isEmpty)) {
        updates['customerPhotoUrl'] = customerPhotoUrl;
      }
      if (technicianPhotoUrl != null &&
          technicianPhotoUrl.isNotEmpty &&
          (data['technicianPhotoUrl'] == null ||
              (data['technicianPhotoUrl'] as String).isEmpty)) {
        updates['technicianPhotoUrl'] = technicianPhotoUrl;
      }
      if (updates.isNotEmpty) await ref.update(updates);
    }
  }

  /// Pre-booking chat: chatId = sorted(customerId, technicianId) dipisah "_"
  /// Sehingga satu pasangan customer-teknisi hanya punya 1 pre-booking room.
  static String preChatId(String customerId, String technicianId) {
    final ids = [customerId, technicianId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Pastikan pre-booking chat room ada. Tidak butuh bookingId.
  Future<void> ensurePreChatExists({
    required String customerId,
    required String customerName,
    required String technicianId,
    required String technicianName,
    String? customerPhotoUrl,
    String? technicianPhotoUrl,
  }) async {
    final chatId = preChatId(customerId, technicianId);
    final ref = _db.collection('chats').doc(chatId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'bookingId': chatId, // pakai chatId sebagai bookingId placeholder
        'customerId': customerId,
        'technicianId': technicianId,
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
    } else {
      // Migrate dokumen lama yang mungkin belum punya field customerId/technicianId.
      // Tanpa field ini, otherName() tidak bisa menentukan siapa pihak lain.
      await ref.set({
        'customerId': customerId,
        'technicianId': technicianId,
        'customerName': customerName,
        'technicianName': technicianName,
        'customerPhotoUrl': customerPhotoUrl,
        'technicianPhotoUrl': technicianPhotoUrl,
      }, SetOptions(merge: true));
    }
  }

  // ── Send message ───────────────────────────────────────────────
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && (imageUrl == null || imageUrl.isEmpty)) return;

    final batch = _db.batch();
    final msgRef =
        _db.collection('chats').doc(chatId).collection('messages').doc();

    batch.set(msgRef, {
      'senderId': senderId,
      'senderName': senderName,
      'text': trimmed,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    final lastMsg = imageUrl != null ? '📷 Foto' : trimmed;
    batch.set(
      _db.collection('chats').doc(chatId),
      {
        'lastMessage': lastMsg,
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
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(ChatMessage.fromFirestore).toList());
  }

  // ── Stream inbox ───────────────────────────────────────────────
  /// Stream semua chat room milik [userId], diurutkan berdasarkan pesan terakhir.
  /// Sort dilakukan client-side untuk menghindari composite index.
  Stream<List<ChatRoomData>> streamUserChats(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snap) {
      final rooms = snap.docs
          .map((d) => ChatRoomData.fromFirestore(d, userId))
          .toList();
      rooms.sort((a, b) {
        final at = a.lastMessageAt;
        final bt = b.lastMessageAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
      return rooms;
    });
  }

  // ── Delete chat room ──────────────────────────────────────────
  Future<void> deleteChat(String chatId) async {
    // Delete messages first (best-effort — don't block document deletion if
    // subcollection delete fails due to security rules)
    try {
      var snap = await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .limit(200)
          .get();

      while (snap.docs.isNotEmpty) {
        final batch = _db.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        snap = await _db
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .limit(200)
            .get();
      }
    } catch (_) {
      // Ignore subcollection delete errors; proceed to delete the chat document
    }

    // Always delete the chat document itself
    await _db.collection('chats').doc(chatId).delete();
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

// ── ChatRoomData model ────────────────────────────────────────────────────
class ChatRoomData {
  final String chatId;
  final String customerId;
  final String technicianId;
  final String customerName;
  final String technicianName;
  final String? customerPhotoUrl;
  final String? technicianPhotoUrl;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String lastSenderId;
  /// true = pre-booking konsultasi, false = booking aktif
  final bool isPreBooking;
  /// Urutan asli dari Firestore: [customerId, technicianId]
  final List<String> participants;

  const ChatRoomData({
    required this.chatId,
    required this.customerId,
    required this.technicianId,
    required this.customerName,
    required this.technicianName,
    required this.lastMessage,
    required this.lastSenderId,
    required this.isPreBooking,
    required this.participants,
    this.customerPhotoUrl,
    this.technicianPhotoUrl,
    this.lastMessageAt,
  });

  factory ChatRoomData.fromFirestore(DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>;
    final bookingId = data['bookingId'] as String? ?? '';
    // pre-booking chatId format: "uid1_uid2" (contains underscore)
    final isPreBooking = bookingId.contains('_');
    final parts = (data['participants'] as List?)?.cast<String>() ?? [];
    return ChatRoomData(
      chatId: doc.id,
      customerId: data['customerId'] as String? ?? '',
      technicianId: data['technicianId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      technicianName: data['technicianName'] as String? ?? '',
      customerPhotoUrl: data['customerPhotoUrl'] as String?,
      technicianPhotoUrl: data['technicianPhotoUrl'] as String?,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastSenderId: data['lastSenderId'] as String? ?? '',
      isPreBooking: isPreBooking,
      participants: parts,
    );
  }

  /// Nama pihak lain (bukan current user).
  /// Jika customerId tersedia, gunakan itu. Jika tidak (dokumen lama),
  /// gunakan participants[0] sebagai customerId (urutan penyimpanan selalu
  /// [customerId, technicianId] di ensureChatExists & ensurePreChatExists).
  String otherName(String currentUserId) {
    final custId = customerId.isNotEmpty ? customerId
        : (participants.isNotEmpty ? participants[0] : '');
    return currentUserId == custId ? technicianName : customerName;
  }

  /// Foto pihak lain.
  String? otherPhotoUrl(String currentUserId) {
    final custId = customerId.isNotEmpty ? customerId
        : (participants.isNotEmpty ? participants[0] : '');
    return currentUserId == custId ? technicianPhotoUrl : customerPhotoUrl;
  }
}

// ── ChatMessage model ──────────────────────────────────────────────────────
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.imageUrl,
    this.isRead = false,
  });

  bool get isImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}

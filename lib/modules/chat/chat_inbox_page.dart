import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../services/chat_service.dart';
import 'chat_inbox_controller.dart';

class ChatInboxPage extends GetView<ChatInboxController> {
  const ChatInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.chatRooms.isEmpty) {
          return const _EmptyInboxState();
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: controller.chatRooms.length,
          itemBuilder: (_, i) => _ChatRoomTile(
            room: controller.chatRooms[i],
            currentUserId: controller.currentUserId,
          ),
        );
      }),
    );
  }
}

// ── Chat Room Tile ─────────────────────────────────────────────────────────
class _ChatRoomTile extends StatelessWidget {
  final ChatRoomData room;
  final String currentUserId;

  const _ChatRoomTile({required this.room, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final name = room.otherName(currentUserId);
    final photoUrl = room.otherPhotoUrl(currentUserId);
    final lastMsg = room.lastMessage.isEmpty ? 'No messages yet' : room.lastMessage;
    final timeLabel = room.lastMessageAt != null ? _formatTime(room.lastMessageAt!) : '';

    // Ada pesan belum dibaca jika pesan terakhir bukan dari current user
    final hasUnread = room.lastMessage.isNotEmpty &&
        room.lastSenderId.isNotEmpty &&
        room.lastSenderId != currentUserId;

    return GestureDetector(
      onTap: _openChat,
      onLongPress: () => _confirmDelete(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasUnread ? const Color(0xFFF5F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _AvatarCircle(name: name, photoUrl: photoUrl, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasUnread
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: hasUnread
                              ? const Color(0xFF4163FF)
                              : const Color(0xFF94A3B8),
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF6B7280),
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (hasUnread)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4163FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: room.isPreBooking
                              ? const Color(0xFFEEF2FF)
                              : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          room.isPreBooking ? 'CONSULT' : 'BOOKING',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: room.isPreBooking
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Conversation',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text(
            'This conversation will be permanently deleted for both parties.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<ChatInboxController>().deleteChat(room.chatId);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    Get.toNamed(AppRoutes.chat, arguments: {
      'chatId': room.chatId,
      // Untuk booking chat, chatId == bookingId — dipakai oleh ChatController
      // agar streaming status booking tetap berjalan
      if (!room.isPreBooking) 'bookingId': room.chatId,
      'otherPartyName': room.otherName(currentUserId),
      'otherPartyPhotoUrl': room.otherPhotoUrl(currentUserId),
    });
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
class _EmptyInboxState extends StatelessWidget {
  const _EmptyInboxState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 36, color: Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start a chat with a technician\nfrom their detail page',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9CA3AF), height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Avatar helper ──────────────────────────────────────────────────────────
class _AvatarCircle extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  const _AvatarCircle({required this.name, this.photoUrl, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFDCE7FB),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.75,
          color: const Color(0xFF3654FF),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/chat_service.dart';
import 'chat_controller.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: _ChatAppBar(ctrl: ctrl),
      body: Column(
        children: [
          Expanded(child: _MessageList(ctrl: ctrl)),
          Obx(() => ctrl.sessionClosed.value
              ? _ClosedSessionBanner()
              : _InputBar(ctrl: ctrl)),
        ],
      ),
    );
  }
}

// ── AppBar ─────────────────────────────────────────────────────────────────
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatController ctrl;
  const _ChatAppBar({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          _AvatarCircle(
            name: ctrl.otherPartyName,
            photoUrl: ctrl.otherPartyPhotoUrl,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Text(
            ctrl.otherPartyName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ── Message List ───────────────────────────────────────────────────────────
class _MessageList extends StatefulWidget {
  final ChatController ctrl;
  const _MessageList({required this.ctrl});

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msgs = widget.ctrl.messages;

      if (widget.ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (msgs.isEmpty) {
        return const Center(
          child: Text(
            'No messages yet.\nStart a conversation with the technician.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), height: 1.6),
          ),
        );
      }

      // Scroll ke bawah saat pesan baru masuk
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      return ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        itemCount: msgs.length,
        itemBuilder: (context, index) {
          final msg = msgs[index];
          final prevMsg = index > 0 ? msgs[index - 1] : null;
          final isMine = widget.ctrl.isMine(msg);

          // Tampilkan date separator jika beda hari
          final showDate = prevMsg == null ||
              !_isSameDay(prevMsg.createdAt, msg.createdAt);

          return Column(
            children: [
              if (showDate) _DateSeparator(date: msg.createdAt),
              _MessageBubble(
                message: msg,
                isMine: isMine,
                showTail: index == msgs.length - 1 ||
                    msgs[index + 1].senderId != msg.senderId,
              ),
            ],
          );
        },
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Date Separator ─────────────────────────────────────────────────────────
class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'TODAY';
    if (d == today.subtract(const Duration(days: 1))) return 'YESTERDAY';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EDF5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _label(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7487),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Message Bubble ─────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool showTail;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.showTail = false,
  });

  String _timeLabel() {
    final h = message.createdAt.hour.toString().padLeft(2, '0');
    final m = message.createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    const myBg = Color(0xFFA5B8FB);   // biru muda sesuai Figma
    const otherBg = Colors.white;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isMine ? 40 : 0,
          right: isMine ? 0 : 40,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.isImage)
              // ── Image bubble ───────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMine ? 18 : (showTail ? 4 : 18)),
                  bottomRight: Radius.circular(isMine ? (showTail ? 4 : 18) : 18),
                ),
                child: Image.network(
                  message.imageUrl!,
                  width: MediaQuery.of(context).size.width * 0.65,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          height: 180,
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                ),
              )
            else
              // ── Text bubble ────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMine ? myBg : otherBg,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMine ? 18 : (showTail ? 4 : 18)),
                    bottomRight: Radius.circular(isMine ? (showTail ? 4 : 18) : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMine ? const Color(0xFF1E2A4A) : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _timeLabel(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '• Sent',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ── Input Bar ──────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final ChatController ctrl;
  const _InputBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      child: Row(
        children: [
          // Photo button
          Obx(() => GestureDetector(
                onTap: ctrl.isUploadingPhoto.value ? null : ctrl.sendPhoto,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ctrl.isUploadingPhoto.value
                      ? const Padding(
                          padding: EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF4163FF)),
                        )
                      : const Icon(Icons.add_photo_alternate_outlined,
                          size: 20, color: Color(0xFF6B7487)),
                ),
              )),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: TextField(
              controller: ctrl.inputController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Color(0xFFB7C0D2)),
                filled: true,
                fillColor: const Color(0xFFF5F7FB),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => ctrl.sendMessage(),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          Obx(() => GestureDetector(
                onTap: ctrl.isSending.value ? null : ctrl.sendMessage,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: ctrl.isSending.value
                        ? const Color(0xFF94A3B8)
                        : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      size: 18, color: Colors.white),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Closed Session Banner ──────────────────────────────────────────────────
class _ClosedSessionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 16, color: Color(0xFF94A3B8)),
            SizedBox(width: 8),
            Text(
              'Chat session has ended',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar helper ──────────────────────────────────────────────────────────
class _AvatarCircle extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  const _AvatarCircle(
      {required this.name, this.photoUrl, this.radius = 20});

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
          fontSize: radius * 0.8,
          color: const Color(0xFF3654FF),
        ),
      ),
    );
  }
}

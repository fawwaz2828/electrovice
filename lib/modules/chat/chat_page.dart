import 'package:flutter/material.dart';
import 'package:get/get.dart';
<<<<<<< HEAD
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
          _InputBar(ctrl: ctrl),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctrl.otherPartyName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'ONLINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF22C55E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
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
            'Belum ada pesan.\nMulai percakapan dengan teknisi.',
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
    if (d == today) return 'HARI INI';
    if (d == today.subtract(const Duration(days: 1))) return 'KEMARIN';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
=======

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late AnimationController _typingCtrl;
  late Animation<double> _typingAnim;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          "Hello! I'm your assigned technician. Could you please send over a photo of the device's damage so I can assess the repair cost?",
      isFromTechnician: true,
      time: '09:41 AM',
      status: 'Delivered',
    ),
    _ChatMessage(
      text:
          'Sure thing. Here is the crack on the display. It happened after a small drop.',
      isFromTechnician: false,
      time: '09:44 AM',
    ),
  ];

  final List<String> _quickReplies = [
    'Bala bala bala',
    'Bala bala bala',
    'Bala bala bala',
  ];

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _typingAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _typingCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isFromTechnician: false,
        time: _nowTime(),
      ));
      _inputCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _nowTime() {
    final now = DateTime.now();
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    return '${hour.toString().padLeft(2, '0')}:$m $ampm';
>>>>>>> origin/main
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    final techName = Get.arguments?['techName'] as String? ?? 'Alex Johnson';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(techName),
            Expanded(
              child: ListView(
                controller: _scrollCtrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildDateSeparator('TODAY'),
                  ..._messages.map((m) => _buildMessageBubble(m)),
                  _buildTypingIndicator(techName),
                ],
              ),
            ),
            _buildQuickReplies(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ONLINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF22C55E),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded,
              color: Color(0xFF475569), size: 22),
        ],
      ),
    );
  }

  // ── Date Separator ───────────────────────────────────────────
  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.8,
>>>>>>> origin/main
            ),
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
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
                    '• Terkirim',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
=======

  // ── Message Bubble ───────────────────────────────────────────
  Widget _buildMessageBubble(_ChatMessage msg) {
    final isTech = msg.isFromTechnician;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isTech ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isTech
                    ? const Color(0xFFBDD3FF)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isTech ? 4 : 18),
                  bottomRight: Radius.circular(isTech ? 18 : 4),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isTech
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                msg.time,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (msg.status != null) ...[
                const Text(
                  ' • ',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
                Text(
                  msg.status!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Typing Indicator ─────────────────────────────────────────
  Widget _buildTypingIndicator(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _typingAnim,
            builder: (context, child) => Opacity(
              opacity: _typingAnim.value,
              child: Text(
                '${name.split(' ').first.toUpperCase()} IS TYPING...',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFBDD3FF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnim,
              builder: (context, child) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        const Color(0xFF93C5FD),
                        const Color(0xFF1D4ED8),
                        (((_typingAnim.value + i * 0.3) % 1.0)),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Replies ────────────────────────────────────────────
  Widget _buildQuickReplies() {
    return Container(
      height: 46,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _quickReplies.length,
        separatorBuilder: (_, i) => const SizedBox(width: 10),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            setState(() {
              _messages.add(_ChatMessage(
                text: _quickReplies[i],
                isFromTechnician: false,
                time: _nowTime(),
              ));
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _quickReplies[i],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Input Bar ────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_photo_alternate_outlined,
                  color: Color(0xFF475569), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(22),
                  border:
                      Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _inputCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Describe the issue...',
                    hintStyle: TextStyle(
                        color: Color(0xFFADB5BD), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
>>>>>>> origin/main
          ],
        ),
      ),
    );
  }
}

<<<<<<< HEAD
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
          // Camera button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_photo_alternate_outlined,
                  size: 20, color: Color(0xFF6B7487)),
            ),
          ),
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
                hintText: 'Ketik pesan...',
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
=======
class _ChatMessage {
  final String text;
  final bool isFromTechnician;
  final String time;
  final String? status;

  const _ChatMessage({
    required this.text,
    required this.isFromTechnician,
    required this.time,
    this.status,
  });
>>>>>>> origin/main
}

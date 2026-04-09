import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  }

  @override
  Widget build(BuildContext context) {
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
            ),
          ),
        ),
      ),
    );
  }

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
          ],
        ),
      ),
    );
  }
}

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
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';
import '../../services/booking_service.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'technician_controller.dart';

class RepairApprovalPage extends StatefulWidget {
  const RepairApprovalPage({super.key});

  @override
  State<RepairApprovalPage> createState() => _RepairApprovalPageState();
}

class _RepairApprovalPageState extends State<RepairApprovalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Capture booking ID now — before activeOrder becomes null after status→done
    final ctrl = Get.find<TechnicianController>();
    final bookingId =
        ctrl.activeOrder.value?.bookingId ?? ctrl.selectedOrder.value?.bookingId;

    if (bookingId != null) {
      // Listen directly to this booking's Firestore doc.
      // streamBookingById includes ALL statuses, so we reliably get the done event
      // even after the order leaves streamTechnicianOrders.
      _sub = BookingService()
          .streamBookingById(bookingId)
          .listen((booking) {
        if (booking == null) return;
        if (booking.status == BookingStatus.done) {
          _sub?.cancel();
          Get.offAllNamed(AppRoutes.jobSummary, arguments: booking);
        }
      });
    }
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _sub?.cancel();
    super.dispose();
  }

  String _rp(int v) {
    if (v == 0) return 'Rp 0';
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TechnicianController>();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: const TechnicianNavBar(selectedItem: AppNavItem.active),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ── AppBar ──────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Repair Approval',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // ── Animated waiting indicator ──────────────────────
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: AnimatedBuilder(
                    animation: _spinCtrl,
                    builder: (_, child) {
                      return CustomPaint(
                        painter: _DashedCirclePainter(
                            progress: _spinCtrl.value),
                        child: child,
                      );
                    },
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 44,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Title ───────────────────────────────────────────
              const Center(
                child: Text(
                  'Wait customer\nresponse',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Estimated waiting time: 5 - 10 minutes',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // ── Cost Summary ────────────────────────────────────
              Obx(() {
                final order =
                    ctrl.activeOrder.value ?? ctrl.selectedOrder.value;
                final total = order?.finalTotalAmount ?? order?.estimatedPrice ?? 0;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'COST SUMMARY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _rp(total),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // ── Chat button ─────────────────────────────────────
              Obx(() {
                final order =
                    ctrl.activeOrder.value ?? ctrl.selectedOrder.value;
                return OutlinedButton.icon(
                  onPressed: order == null
                      ? null
                      : () => Get.toNamed(
                            AppRoutes.chat,
                            arguments: {
                              'chatId': order.bookingId,
                              'otherPartyName': order.userName,
                              'bookingDoc': order,
                            },
                          ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: Color(0xFF0F172A)),
                  label: const Text(
                    'CHAT',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.8,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // ── Important Information ───────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: Color(0xFF0F172A)),
                        SizedBox(width: 8),
                        Text(
                          'Important information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: const Color(0xFF16A34A),
                      title: 'If approved',
                      subtitle:
                          'You will be taken directly to the repair stage and can begin working.',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.cancel_outlined,
                      iconColor: const Color(0xFFDC2626),
                      title: 'If rejected',
                      subtitle:
                          'Work is stopped. The customer will only pay the standard diagnostic fee.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Dashed spinning circle painter ───────────────────────────────────────
class _DashedCirclePainter extends CustomPainter {
  final double progress;
  _DashedCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const dashCount = 20;
    const dashLength = 0.12;
    const gapLength = (math.pi * 2 - dashCount * dashLength) / dashCount;
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final offset = progress * math.pi * 2;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (dashLength + gapLength) + offset;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength,
        false,
        paint,
      );
    }

    // Two accent dots
    for (int i = 0; i < 2; i++) {
      final angle = offset + i * math.pi;
      canvas.drawCircle(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        4,
        Paint()..color = const Color(0xFF0F172A),
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.progress != progress;
}

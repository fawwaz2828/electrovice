import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../models/notification_model.dart';
import 'notification_controller.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.unreadCount.value == 0) return const SizedBox();
            return TextButton(
              onPressed: controller.markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF4163FF),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _NotificationSkeleton();
        }
        if (controller.notifications.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 72, color: Color(0xFFEEF0F5)),
          itemBuilder: (context, index) {
            final item = controller.notifications[index];
            return _NotificationTile(
              item: item,
              onTap: () => _onTap(item),
            );
          },
        );
      }),
    );
  }

  void _onTap(NotificationItem item) {
    if (!item.isRead) controller.markAsRead(item.id);
    Get.back();

    final isTechnician = controller.userRole == 'technician';

    switch (item.type) {
      // ── Notif teknisi ─────────────────────────────────────────────
      case NotifType.newOrder:
      case NotifType.orderCancelled:
      case NotifType.paymentConfirmed:
        if (isTechnician) Get.toNamed(AppRoutes.activeOrders);
        break;

      // ── Notif customer: order sedang berjalan ─────────────────────
      case NotifType.orderAccepted:
      case NotifType.onProgress:
      case NotifType.awaitingPayment:
        if (!isTechnician) Get.toNamed(AppRoutes.orderTracking);
        break;

      // ── Notif customer: order ditolak ─────────────────────────────
      case NotifType.orderDeclined:
        if (!isTechnician) Get.toNamed(AppRoutes.customerOrders);
        break;

      // ── Chat: buka inbox ─────────────────────────────────────────
      case NotifType.chat:
        Get.toNamed(AppRoutes.chatInbox);
        break;

      default:
        break;
    }
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(item.type);
    final color = _colorFor(item.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isRead ? Colors.white : const Color(0xFFF0F4FF),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          item.isRead ? FontWeight.w600 : FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(item.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4163FF),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
        NotifType.newOrder => Icons.assignment_rounded,
        NotifType.orderAccepted => Icons.check_circle_rounded,
        NotifType.orderDeclined => Icons.cancel_rounded,
        NotifType.orderCancelled => Icons.cancel_rounded,
        NotifType.onProgress => Icons.build_rounded,
        NotifType.awaitingPayment => Icons.receipt_long_rounded,
        NotifType.paymentConfirmed => Icons.payments_rounded,
        NotifType.chat => Icons.chat_bubble_rounded,
        _ => Icons.notifications_rounded,
      };

  Color _colorFor(String type) => switch (type) {
        NotifType.newOrder => const Color(0xFF4163FF),
        NotifType.orderAccepted => const Color(0xFF10B981),
        NotifType.orderDeclined => const Color(0xFFEF4444),
        NotifType.orderCancelled => const Color(0xFFEF4444),
        NotifType.onProgress => const Color(0xFF4163FF),
        NotifType.awaitingPayment => const Color(0xFFF59E0B),
        NotifType.paymentConfirmed => const Color(0xFF10B981),
        NotifType.chat => const Color(0xFF8B5CF6),
        _ => const Color(0xFF64748B),
      };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────
class _NotificationSkeleton extends StatefulWidget {
  const _NotificationSkeleton();

  @override
  State<_NotificationSkeleton> createState() => _NotificationSkeletonState();
}

class _NotificationSkeletonState extends State<_NotificationSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box(Color c, {required double w, required double h, double r = 6}) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
            color: c, borderRadius: BorderRadius.circular(r)),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final c = Color.lerp(
            const Color(0xFFE2E8F0), const Color(0xFFF8FAFC), _anim.value)!;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: 6,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 72, color: Color(0xFFEEF0F5)),
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(c, w: 44, h: 44, r: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(c, w: 160, h: 13),
                      const SizedBox(height: 6),
                      _box(c, w: double.infinity, h: 11),
                      const SizedBox(height: 4),
                      _box(c, w: 200, h: 11),
                      const SizedBox(height: 8),
                      _box(c, w: 80, h: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 36,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Notifications Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Order notifications will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
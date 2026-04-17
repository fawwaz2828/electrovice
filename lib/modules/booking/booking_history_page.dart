import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../models/booking_document.dart';
import '../../models/booking_model.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'booking_controller.dart';

class BookingHistoryPage extends GetView<BookingController> {
  const BookingHistoryPage({super.key});

  static const Color _bg = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const CustomerNavBar(selectedItem: AppNavItem.history),
      body: SafeArea(
        child: Obx(() {
          final items = controller.orderHistoryData;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order History',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'RECENT ORDERS',
                        style: TextStyle(
                          color: Color(0xFF68738A),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Text('View All', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 14),
                ...List.generate(items.length, (i) {
                  final item = items[i];
                  final doc = controller.bookingHistory.length > i
                      ? controller.bookingHistory[i]
                      : null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: doc == null
                          ? null
                          : () => Get.toNamed(
                                AppRoutes.bookingDetail,
                                arguments: doc,
                              ),
                      child: _HistoryRecordCard(item: item, category: doc?.category ?? ''),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                // Cari booking done yang belum dirating
                Builder(builder: (_) {
                  final unreviewed = controller.bookingHistory
                      .where((b) =>
                          b.status == BookingStatus.done &&
                          b.customerRating == null)
                      .firstOrNull;
                  return _ReviewPromptCard(unreviewedBooking: unreviewed);
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

}

class _HistoryRecordCard extends StatelessWidget {
  const _HistoryRecordCard({required this.item, this.category = ''});

  final OrderHistoryRecord item;
  final String category;

  @override
  Widget build(BuildContext context) {
    final badge = _badge(item.status, category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(badge.$3, color: badge.$2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(item.subtitle, style: TextStyle(color: badge.$2)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badge.$1.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge.$4,
                  style: TextStyle(color: badge.$1, fontWeight: FontWeight.w800, fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              Text(item.dateLabel, style: const TextStyle(color: Color(0xFF7A8293))),
              const Spacer(),
              Text(
                item.amountLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: item.status == OrderHistoryStatus.verificationFailed
                      ? const Color(0xFFD17B20)
                      : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'vehicle':
      case 'kendaraan':
        return Icons.two_wheeler_rounded;
      case 'ac':
        return Icons.ac_unit_rounded;
      default:
        return Icons.devices_rounded;
    }
  }

  (Color, Color, IconData, String) _badge(OrderHistoryStatus status, String cat) {
    final icon = _categoryIcon(cat);
    switch (status) {
      case OrderHistoryStatus.success:
        return (
          const Color(0xFF7B8DEB),
          const Color(0xFF4F5C88),
          icon,
          'DONE',
        );
      case OrderHistoryStatus.canceled:
        return (
          const Color(0xFF9AA2B4),
          const Color(0xFF6D7486),
          icon,
          'CANCELLED',
        );
      case OrderHistoryStatus.verificationFailed:
        return (
          const Color(0xFFD79A2B),
          const Color(0xFFB3671F),
          icon,
          'VERIF FAILED',
        );
      case OrderHistoryStatus.active:
        return (
          const Color(0xFF3B82F6),
          const Color(0xFF1D4ED8),
          Icons.autorenew_rounded,
          'ACTIVE',
        );
      case OrderHistoryStatus.awaitingPayment:
        return (
          const Color(0xFF10B981),
          const Color(0xFF047857),
          Icons.payment_rounded,
          'PAY',
        );
    }
  }
}

class _ReviewPromptCard extends StatelessWidget {
  final BookingDocument? unreviewedBooking;
  const _ReviewPromptCard({this.unreviewedBooking});

  @override
  Widget build(BuildContext context) {
    if (unreviewedBooking == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE7FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How was your experience?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Leave a review for ${unreviewedBooking!.technicianName}.',
            style: const TextStyle(color: Color(0xFF67728B)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Get.toNamed(
              AppRoutes.review,
              arguments: unreviewedBooking,
            ),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
            child: const Text('WRITE REVIEW',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HISTORY SKELETON
// ═══════════════════════════════════════════════════════════════
class _HistorySkeleton extends StatefulWidget {
  const _HistorySkeleton();

  @override
  State<_HistorySkeleton> createState() => _HistorySkeletonState();
}

class _HistorySkeletonState extends State<_HistorySkeleton>
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
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final c = Color.lerp(
          const Color(0xFFE2E8F0),
          const Color(0xFFF8FAFC),
          _anim.value,
        )!;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(c, w: 160, h: 28, r: 8),
              const SizedBox(height: 14),
              _box(c, w: 120, h: 14, r: 6),
              const SizedBox(height: 14),
              ...List.generate(3, (index) => _skeletonCard(c)),
            ],
          ),
        );
      },
    );
  }

  Widget _skeletonCard(Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _box(c, w: 42, h: 42, r: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(c, w: 130, h: 16, r: 6),
                    const SizedBox(height: 6),
                    _box(c, w: 90, h: 12, r: 5),
                  ],
                ),
              ),
              _box(c, w: 70, h: 28, r: 10),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _box(c, w: 100, h: 13, r: 5),
              const Spacer(),
              _box(c, w: 70, h: 13, r: 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _box(Color c,
      {required double w, required double h, double r = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

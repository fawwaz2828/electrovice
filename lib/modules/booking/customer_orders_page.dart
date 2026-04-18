import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../models/booking_document.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'booking_controller.dart';

class CustomerOrdersPage extends GetView<BookingController> {
  const CustomerOrdersPage({super.key});

  static const Color _bg = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const CustomerNavBar(selectedItem: AppNavItem.order),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingHistory.value) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active Orders',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _OrderCardSkeleton(),
                      ),
                      childCount: 3,
                    ),
                  ),
                ),
              ],
            );
          }

          final activeOrders = controller.bookingHistory
              .where((b) => b.isActive)
              .toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Orders',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeOrders.isEmpty
                            ? 'No ongoing orders'
                            : '${activeOrders.length} order(s) in progress',
                        style: const TextStyle(
                            color: Color(0xFF68738A), fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (activeOrders.isEmpty)
                const SliverFillRemaining(
                    hasScrollBody: false, child: _EmptyOrdersState()),
              if (activeOrders.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OrderCard(
                          booking: activeOrders[i],
                          onTap: () => Get.toNamed(AppRoutes.orderTracking),
                        ),
                      ),
                      childCount: activeOrders.length,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Order Card ─────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final BookingDocument booking;
  final VoidCallback onTap;

  const _OrderCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(booking.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_categoryIcon(booking.category),
                      color: const Color(0xFF4B5563)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _damageTypeLabel(booking.damageType),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.technicianName,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badge.$1.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge.$2,
                    style: TextStyle(
                      color: badge.$1,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(booking.scheduledAt),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const Spacer(),
                Text(
                  booking.estimatedPrice > 0
                      ? 'Rp ${_formatPrice(booking.estimatedPrice)}'
                      : 'Discuss on-site',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (Color, String) _statusBadge(String status) => switch (status) {
        BookingStatus.pending => (const Color(0xFF6B7280), 'PENDING'),
        BookingStatus.confirmed => (const Color(0xFF3B82F6), 'CONFIRMED'),
        BookingStatus.onProgress => (const Color(0xFFF59E0B), 'IN PROGRESS'),
        BookingStatus.awaitingPayment => (const Color(0xFF10B981), 'PAY'),
        _ => (const Color(0xFF6B7280), status.toUpperCase()),
      };

  IconData _categoryIcon(String category) => switch (category) {
        'vehicle' => Icons.two_wheeler_rounded,
        _ => Icons.devices_rounded,
      };

  String _damageTypeLabel(String type) => switch (type) {
        'screen' => 'Screen Damage',
        'battery' => 'Battery Issue',
        'hardware' => 'Hardware Damage',
        'water' => 'Water Damage',
        'camera' => 'Camera Issue',
        _ => 'General Repair',
      };

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]}, $h.00';
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

// ── Done Order Card ────────────────────────────────────────────────────────
// ignore: unused_element
class _DoneOrderCard extends StatelessWidget {
  final BookingDocument booking;
  const _DoneOrderCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final needsReview = booking.customerRating == null;

    return GestureDetector(
      onTap: needsReview
          ? () => Get.toNamed(AppRoutes.review, arguments: booking)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    booking.category == 'vehicle'
                        ? Icons.two_wheeler_rounded
                        : Icons.devices_rounded,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _damageTypeLabel(booking.damageType),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.technicianName,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                if (needsReview)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'WRITE REVIEW',
                      style: TextStyle(
                        color: Color(0xFFEA580C),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  )
                else
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: i < (booking.customerRating ?? 0)
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 22),
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(booking.scheduledAt),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const Spacer(),
                Text(
                  booking.finalTotalAmount != null
                      ? 'Rp ${_formatPrice(booking.finalTotalAmount!)}'
                      : booking.estimatedPrice > 0
                          ? 'Rp ${_formatPrice(booking.estimatedPrice)}'
                          : 'Done',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _damageTypeLabel(String type) => switch (type) {
        'screen' => 'Screen Damage',
        'battery' => 'Battery Issue',
        'hardware' => 'Hardware Damage',
        'water' => 'Water Damage',
        'camera' => 'Camera Issue',
        _ => 'General Repair',
      };

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]}, $h.00';
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

// ── Order Card Skeleton ────────────────────────────────────────────────────
class _OrderCardSkeleton extends StatefulWidget {
  const _OrderCardSkeleton();

  @override
  State<_OrderCardSkeleton> createState() => _OrderCardSkeletonState();
}

class _OrderCardSkeletonState extends State<_OrderCardSkeleton>
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
      builder: (_, __) {
        final c = Color.lerp(
            const Color(0xFFE2E8F0), const Color(0xFFF8FAFC), _anim.value)!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _box(c, w: 42, h: 42, r: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(c, w: 140, h: 14),
                        const SizedBox(height: 6),
                        _box(c, w: 90, h: 11),
                      ],
                    ),
                  ),
                  _box(c, w: 70, h: 26, r: 10),
                ],
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _box(c, w: 100, h: 10),
                  const Spacer(),
                  _box(c, w: 60, h: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _box(Color color, {required double w, required double h, double r = 6}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

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
            child: const Icon(Icons.receipt_long_outlined,
                size: 38, color: Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No active orders',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your ongoing orders\nwill appear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9CA3AF), height: 1.5),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Get.offNamed(AppRoutes.home),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white),
            child: const Text('Find Technician',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

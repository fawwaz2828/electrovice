import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'technician_controller.dart';

class TechnicianActiveOrdersPage extends StatelessWidget {
  const TechnicianActiveOrdersPage({super.key});

  String _damageLabel(String type) => switch (type) {
        'screen' => 'Screen Replacement',
        'battery' => 'Battery Replacement',
        'hardware' => 'Hardware Repair',
        'water' => 'Water Damage',
        'camera' => 'Camera Repair',
        _ => 'General Repair',
      };

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TechnicianController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      extendBody: true,
      bottomNavigationBar: const TechnicianNavBar(selectedItem: AppNavItem.active),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Obx(() {
                final count = controller.incomingOrders
                    .where((o) =>
                        o.status == BookingStatus.confirmed ||
                        o.status == BookingStatus.onProgress)
                    .length;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Active Orders ($count)',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.isLoadingOrders.value
                          ? null
                          : controller.refreshAll,
                      icon: controller.isLoadingOrders.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded,
                              color: Color(0xFF4163FF)),
                    ),
                  ],
                );
              }),
            ),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoadingOrders.value) {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    itemCount: 3,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: _ActiveOrderSkeleton(),
                    ),
                  );
                }

                final orders = controller.incomingOrders
                    .where((o) =>
                        o.status == BookingStatus.confirmed ||
                        o.status == BookingStatus.onProgress)
                    .toList();

                if (orders.isEmpty) {
                  return _EmptyState(onRefresh: controller.refreshAll);
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshAll,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    itemCount: orders.length,
                    itemBuilder: (_, i) {
                      final order = orders[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ActiveOrderCard(
                          order: order,
                          damageLabel: _damageLabel(order.damageType),
                          dateLabel: _formatDate(order.scheduledAt),
                          onViewDetails: () {
                            controller.selectOrder(order);
                            if (order.status == BookingStatus.confirmed) {
                              Get.toNamed(AppRoutes.verification);
                            } else {
                              Get.toNamed(AppRoutes.activeJob);
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  ORDER CARD
// ─────────────────────────────────────────────────────────────────
class _ActiveOrderCard extends StatelessWidget {
  final BookingDocument order;
  final String damageLabel;
  final String dateLabel;
  final VoidCallback onViewDetails;

  const _ActiveOrderCard({
    required this.order,
    required this.damageLabel,
    required this.dateLabel,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isOnProgress = order.status == BookingStatus.onProgress;
    final statusColor =
        isOnProgress ? const Color(0xFF0061FF) : const Color(0xFF059669);
    final statusLabel = isOnProgress ? 'IN PROGRESS' : 'ON THE WAY';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  damageLabel,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.userName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          // Date + view details
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Active Order Skeleton ──────────────────────────────────────────────────
class _ActiveOrderSkeleton extends StatefulWidget {
  const _ActiveOrderSkeleton();

  @override
  State<_ActiveOrderSkeleton> createState() => _ActiveOrderSkeletonState();
}

class _ActiveOrderSkeletonState extends State<_ActiveOrderSkeleton>
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
                  _box(c, w: 44, h: 44, r: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(c, w: 160, h: 14),
                        const SizedBox(height: 6),
                        _box(c, w: 100, h: 11),
                      ],
                    ),
                  ),
                  _box(c, w: 80, h: 28, r: 10),
                ],
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _box(c, w: 120, h: 10),
                  const Spacer(),
                  _box(c, w: 80, h: 32, r: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _box(Color color,
      {required double w, required double h, double r = 6}) {
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

// ─────────────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final Future<void> Function()? onRefresh;
  const _EmptyState({this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.build_circle_outlined,
                    size: 40,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No active jobs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accepted jobs will appear here',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFCBD5E1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onRefresh != null) ...[
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4163FF),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

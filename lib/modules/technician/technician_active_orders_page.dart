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
                return Text(
                  'Active Orders ($count)',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                );
              }),
            ),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final orders = controller.incomingOrders
                    .where((o) =>
                        o.status == BookingStatus.confirmed ||
                        o.status == BookingStatus.onProgress)
                    .toList();

                if (orders.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
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

// ─────────────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────────────
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
        ],
      ),
    );
  }
}

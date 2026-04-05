import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
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
      bottomNavigationBar: AppBottomNavBar(
        selectedItem: AppNavItem.history,
        onItemSelected: _onNavSelected,
      ),
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
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryRecordCard(item: item),
                  ),
                ),
                const SizedBox(height: 10),
                const _ReviewPromptCard(),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _onNavSelected(AppNavItem item) {
    switch (item) {
      case AppNavItem.home:
        Get.offNamed(AppRoutes.home);
        return;
      case AppNavItem.history:
        return;
      case AppNavItem.order:
        Get.offNamed(AppRoutes.orderTracking);
        return;
      case AppNavItem.profile:
        Get.offNamed(AppRoutes.profile_page);
        return;
      case AppNavItem.active:
        return;
    }
  }
}

class _HistoryRecordCard extends StatelessWidget {
  const _HistoryRecordCard({required this.item});

  final OrderHistoryRecord item;

  @override
  Widget build(BuildContext context) {
    final badge = _badge(item.status);

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
                  color: badge.$1.withOpacity(0.12),
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

  (Color, Color, IconData, String) _badge(OrderHistoryStatus status) {
    switch (status) {
      case OrderHistoryStatus.success:
        return (
          const Color(0xFF7B8DEB),
          const Color(0xFF4F5C88),
          Icons.computer_outlined,
          'SUCCESS',
        );
      case OrderHistoryStatus.canceled:
        return (
          const Color(0xFF9AA2B4),
          const Color(0xFF6D7486),
          Icons.smartphone_rounded,
          'CANCELED',
        );
      case OrderHistoryStatus.verificationFailed:
        return (
          const Color(0xFFD79A2B),
          const Color(0xFFB3671F),
          Icons.ac_unit_rounded,
          'VERIFICATION FAILED',
        );
    }
  }
}

class _ReviewPromptCard extends StatelessWidget {
  const _ReviewPromptCard();

  @override
  Widget build(BuildContext context) {
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
          const Text('Help us improve', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Rate your recent experience with our technicians.',
            style: TextStyle(color: Color(0xFF67728B)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            child: const Text('Leave Review'),
          ),
        ],
      ),
    );
  }
}

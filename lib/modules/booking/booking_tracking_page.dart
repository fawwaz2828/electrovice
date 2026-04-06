import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/booking_model.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'booking_controller.dart';

class BookingTrackingPage extends GetView<BookingController> {
  const BookingTrackingPage({super.key});

  static const Color _bg = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const CustomerNavBar(selectedItem: AppNavItem.order),
      body: SafeArea(
        child: Obx(() {
          final OrderTrackingData tracking = controller.trackingData;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order Tracking',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Icon(Icons.help_outline_rounded, color: Color(0xFF6E7789)),
                  ],
                ),
                const SizedBox(height: 16),
                _LiveMapCard(title: tracking.mapTitle),
                const SizedBox(height: 14),
                _StatusCard(tracking: tracking),
                const SizedBox(height: 14),
                _SecurityCodeCard(code: tracking.securityCode),
                const SizedBox(height: 14),
                _TechnicianContactCard(
                  name: tracking.technicianName,
                  role: tracking.technicianRole,
                  partnerLabel: tracking.partnerLabel,
                  imageUrl: tracking.technicianAvatarUrl,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

}

class _LiveMapCard extends StatelessWidget {
  const _LiveMapCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 10)],
            ),
            child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 10),
          Container(
            height: 205,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9BC46B), Color(0xFF64B8E8)],
              ),
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 13,
                backgroundColor: Color(0xFF3654FF),
                child: CircleAvatar(radius: 9, backgroundColor: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.tracking});

  final OrderTrackingData tracking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT STATUS',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.6),
          ),
          const SizedBox(height: 18),
          ...tracking.statusSteps.map((step) => _StatusStepTile(step: step)),
        ],
      ),
    );
  }
}

class _StatusStepTile extends StatelessWidget {
  const _StatusStepTile({required this.step});

  final TrackingStatusStep step;

  @override
  Widget build(BuildContext context) {
    final activeColor = step.isCurrent ? const Color(0xFF4163FF) : const Color(0xFFE7EBF2);
    final iconColor = step.isCurrent || step.isComplete ? Colors.white : const Color(0xFF9CA5B6);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                child: Icon(
                  step.isCurrent || step.isComplete ? Icons.more_horiz_rounded : Icons.circle_outlined,
                  size: 16,
                  color: iconColor,
                ),
              ),
              Container(width: 2, height: 42, color: const Color(0xFFE6EAF1)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: step.isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: step.isCurrent ? Colors.black : const Color(0xFF9CA5B6),
                    ),
                  ),
                  if (step.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      style: TextStyle(
                        color: step.isCurrent ? const Color(0xFF60697A) : const Color(0xFFB1B8C6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityCodeCard extends StatelessWidget {
  const _SecurityCodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final digits = code.split('');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          const Text(
            'SECURITY VERIFICATION CODE',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.6),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(digits.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 36,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F5FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      digits[index],
                      style: const TextStyle(
                        color: Color(0xFF3654FF),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text(
            'Provide this code to the technician upon arrival.',
            style: TextStyle(color: Color(0xFF737B8C)),
          ),
        ],
      ),
    );
  }
}

class _TechnicianContactCard extends StatelessWidget {
  const _TechnicianContactCard({
    required this.name,
    required this.role,
    required this.partnerLabel,
    this.imageUrl,
  });

  final String name;
  final String role;
  final String partnerLabel;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF94A3B8),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(role, style: const TextStyle(color: Color(0xFF727B8B), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(partnerLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Message'),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.call_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

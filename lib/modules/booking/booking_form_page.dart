import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../models/booking_model.dart';
import 'booking_controller.dart';

class BookingFormPage extends GetView<BookingController> {
  const BookingFormPage({super.key});

  static const Color _bg = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          final CustomerOrderDraft draft = controller.orderDraftData;

          return Column(
            children: [
              const _BookingTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DeviceCard(draft: draft),
                      const SizedBox(height: 20),
                      const _StepHeader(title: '1. SELECT DAMAGE TYPE', trailing: 'Required'),
                      const SizedBox(height: 12),
                      _DamageGrid(selected: draft.selectedDamage),
                      const SizedBox(height: 16),
                      const _NotesCard(),
                      const SizedBox(height: 20),
                      const _StepHeader(title: '2. SCHEDULE SERVICE'),
                      const SizedBox(height: 12),
                      const _ScheduleCard(),
                      const SizedBox(height: 16),
                      _OrderSummaryCard(draft: draft),
                      const SizedBox(height: 16),
                      const _SecurityNoticeCard(),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: SafeArea(
                  top: false,
                  child: FilledButton(
                    onPressed: () => Get.toNamed(AppRoutes.checkout),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('CONFIRM & BOOK', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
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

class _BookingTopBar extends StatelessWidget {
  const _BookingTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Text('Create Order', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.draft});

  final CustomerOrderDraft draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smartphone_rounded, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(draft.deviceName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(draft.serialNumber, style: const TextStyle(color: Color(0xFF727B8B))),
                const SizedBox(height: 6),
                if (draft.isUnderWarranty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Under Warranty',
                      style: TextStyle(
                        color: Color(0xFF7A8599),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF5D6780),
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        if (trailing != null) Text(trailing!, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _DamageGrid extends StatelessWidget {
  const _DamageGrid({required this.selected});

  final DamageType selected;

  @override
  Widget build(BuildContext context) {
    final items = <(DamageType, IconData, String)>[
      (DamageType.screen, Icons.screenshot_monitor_outlined, 'Screen'),
      (DamageType.battery, Icons.battery_4_bar_rounded, 'Battery'),
      (DamageType.hardware, Icons.memory_rounded, 'Hardware'),
      (DamageType.water, Icons.water_drop_outlined, 'Water'),
      (DamageType.camera, Icons.camera_alt_outlined, 'Camera'),
      (DamageType.other, Icons.more_horiz_rounded, 'Other'),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        final isSelected = item.$1 == selected;
        return Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? Colors.black : const Color(0xFFE5E9F2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.$2, color: isSelected ? Colors.white : Colors.black),
              const SizedBox(height: 8),
              Text(
                item.$3,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, size: 18, color: Color(0xFF6B7487)),
              SizedBox(width: 8),
              Text(
                'ADDITIONAL NOTES',
                style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF5D6780)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 108,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Describe the issue in detail..',
              style: TextStyle(color: Color(0xFFB7C0D2)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _SmallIconButton(icon: Icons.camera_alt_outlined),
              const SizedBox(width: 8),
              _SmallIconButton(icon: Icons.attach_file_rounded),
              const Spacer(),
              const Text(
                'Autosaved 14:42',
                style: TextStyle(color: Color(0xFF99A2B5), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF657084)),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    const dateItems = ['OCT\n24\nThu', 'OCT\n25\nFri', 'OCT\n26\nSat', 'OCT\n27\nSun'];
    const timeItems = ['09:00 AM', '11:30 AM', '02:00 PM', '04:30 PM'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dateItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final isSelected = index == 0;
                return Container(
                  width: 58,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : const Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      dateItems[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: timeItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final isSelected = index == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFDCE5FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD8DEEB)),
                  ),
                  child: Center(
                    child: Text(
                      timeItems[index],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.draft});

  final CustomerOrderDraft draft;

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
            'ORDER SUMMARY',
            style: TextStyle(color: Color(0xFF5D6780), fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          _row('Service Fee (Visit)', draft.serviceFee),
          const SizedBox(height: 12),
          _row('Parts (Est. Screen Replacement)', draft.partsEstimate),
          const SizedBox(height: 12),
          _row('Taxes & Logistics', draft.taxesAndLogistics),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text('Total Estimate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                '\$${draft.totalEstimate.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF3654FF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double amount) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF5F6778)))),
        Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SecurityNoticeCard extends StatelessWidget {
  const _SecurityNoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5E1FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'A 6-digit security code will be generated upon confirmation. Provide this only when the technician arrives to verify the service.',
              style: TextStyle(color: Color(0xFF365081), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

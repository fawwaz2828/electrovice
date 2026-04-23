import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/booking_model.dart';
import 'booking_controller.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const Color _bg   = Color(0xFFF2F3F7);
const Color _card = Colors.white;
const Color _ink  = Color(0xFF0A0A0A);
const Color _muted= Color(0xFF64748B);
const Color _blue = Color(0xFF0061FF);

String _rp(double v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buf.write('.');
    buf.write(s[i]);
    count++;
  }
  return 'Rp ${buf.toString().split('').reversed.join()}';
}

class CheckoutPage extends GetView<BookingController> {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          final CheckoutSummary checkout = controller.checkoutData;

          return Column(
            children: [
              // ── Top bar ──────────────────────────────────────────
              const _CheckoutTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: [
                      // ── 1. Current Repair Card ───────────────────
                      _CurrentRepairCard(checkout: checkout),
                      const SizedBox(height: 14),

                      // ── 2. Jadwal Repair ─────────────────────────
                      _JadwalRepairCard(),
                      const SizedBox(height: 14),

                      // ── 3. Biaya Tambahan ────────────────────────
                      const _BiayaTambahanCard(),
                      const SizedBox(height: 14),

                      // ── 4. Cost Breakdown ────────────────────────
                      _CostBreakdown(checkout: checkout),
                      const SizedBox(height: 14),

                      // ── Footer badges ────────────────────────────
                      const _CheckoutFooterBadges(),
                    ],
                  ),
                ),
              ),
              // ── Order Now button ──────────────────────────────────
              Container(
                color: _card,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: SafeArea(
                  top: false,
                  child: Obx(() => FilledButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitBooking(),
                    style: FilledButton.styleFrom(
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: controller.isSubmitting.value
                        ? const Text('Processing...',
                            style: TextStyle(fontWeight: FontWeight.w800))
                        : const Text('Order Now',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  )),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────
class _CheckoutTopBar extends StatelessWidget {
  const _CheckoutTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const Text(
            'Checkout',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
          ),
        ],
      ),
    );
  }
}

// ── 1. Current Repair Card ────────────────────────────────────────────────
class _CurrentRepairCard extends GetView<BookingController> {
  final CheckoutSummary checkout;
  const _CurrentRepairCard({required this.checkout});

  @override
  Widget build(BuildContext context) {
    final name = controller.selectedTechnician.value?.name ?? checkout.currentRepairTitle;
    final scheduled = checkout.scheduledForLabel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + icon
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Scheduled for $scheduled',
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.laptop_mac_rounded, color: _muted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Verified badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: _blue, size: 16),
                SizedBox(width: 8),
                Text(
                  'Verified Professional Service assigned',
                  style: TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

// ── 2. Jadwal Repair Card ─────────────────────────────────────────────────
class _JadwalRepairCard extends GetView<BookingController> {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Repair Schedule',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 14),
          // ── Date + Time row ───────────────────────────────────
          Obx(() {
            final dt = controller.scheduledAt.value;
            final day = dt.day;
            final month = _months[dt.month - 1];
            final year = dt.year;
            final hour = dt.hour.toString().padLeft(2, '0');
            final weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
            final dayName = weekdays[dt.weekday - 1];

            return Row(
              children: [
                // Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$day $month $year',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      Text(
                        dayName,
                        style: const TextStyle(fontSize: 12, color: _muted),
                      ),
                    ],
                  ),
                ),
                // Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Time $hour:00',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const Text(
                      'time',
                      style: TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ],
            );
          }),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          // ── Address row ───────────────────────────────────────
          Obx(() {
            final address = controller.userAddress.value;
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.isEmpty ? 'Full Address' : address,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: address.isEmpty ? _muted : _ink,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Address',
                        style: TextStyle(fontSize: 11, color: _muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'GPS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _muted,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── 3. Biaya Tambahan Card ────────────────────────────────────────────────
class _BiayaTambahanCard extends GetView<BookingController> {
  const _BiayaTambahanCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final checkout = controller.checkoutData;
      final distKm = controller.selectedTechnician.value?.distanceKm ?? 0;
      final distLabel = distKm >= 10 ? '≥10 km' : '<10 km';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF0A0A0A), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Fees',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 14),
            // Admin fee
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Fee (10%)',
                        style: TextStyle(fontSize: 13, color: _muted),
                      ),
                      const Text(
                        'Based on service price estimate',
                        style: TextStyle(fontSize: 11, color: _muted),
                      ),
                    ],
                  ),
                ),
                Text(
                  _rp(checkout.adminFee),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Delivery fee
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Fee',
                        style: TextStyle(fontSize: 13, color: _muted),
                      ),
                      Text(
                        'Distance $distLabel from workshop',
                        style: const TextStyle(fontSize: 11, color: _muted),
                      ),
                    ],
                  ),
                ),
                Text(
                  _rp(checkout.deliveryFee),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ── 4. Cost Breakdown ─────────────────────────────────────────────────────
class _CostBreakdown extends StatelessWidget {
  final CheckoutSummary checkout;
  const _CostBreakdown({required this.checkout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Breakdown',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 14),
          _CostRow(label: 'Service Fee', value: checkout.serviceFee),
          const SizedBox(height: 8),
          _CostRow(label: checkout.partsLabel, value: checkout.partsFee),
          const SizedBox(height: 8),
          _CostRow(label: 'Admin Fee (10%)', value: checkout.adminFee),
          const SizedBox(height: 8),
          _CostRow(label: 'Delivery Fee', value: checkout.deliveryFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink),
              ),
              const Spacer(),
              Text(
                _rp(checkout.totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final double value;
  const _CostRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: _muted),
          ),
        ),
        Text(
          _rp(value),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ],
    );
  }
}

// ── Footer Badges ─────────────────────────────────────────────────────────
class _CheckoutFooterBadges extends StatelessWidget {
  const _CheckoutFooterBadges();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 12, color: _muted),
        const SizedBox(width: 4),
        const Text(
          'SECURE ENCRYPTION',
          style: TextStyle(fontSize: 10, color: _muted, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 20),
        Container(
          width: 1,
          height: 12,
          color: Color(0xFFE2E8F0),
        ),
        const SizedBox(width: 20),
        const Icon(Icons.verified_user_outlined, size: 12, color: _muted),
        const SizedBox(width: 4),
        const Text(
          'FRAUD PROTECTION',
          style: TextStyle(fontSize: 10, color: _muted, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

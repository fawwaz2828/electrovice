import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'booking_controller.dart';

class PayServicePage extends GetView<BookingController> {
  const PayServicePage({super.key});

  void _showPhotoViewer(
      BuildContext context, List<String> urls, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: urls.length,
              itemBuilder: (_, i) => InteractiveViewer(
                child: Center(
                  child: Image.network(urls[i], fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar:
          const CustomerNavBar(selectedItem: AppNavItem.order),
      body: SafeArea(
        child: Obx(() {
          final booking = controller.activeBooking.value;
          final diagnoseFee = booking?.estimatedPrice ?? 0;
          final finalTotal = booking?.finalTotalAmount ?? diagnoseFee;
          // Visit fee = total − diagnose fee (service + parts)
          final visitFee = finalTotal - diagnoseFee;

          return Column(
            children: [
              // ── AppBar ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF0F172A)),
                      onPressed: () => Get.back(),
                    ),
                    const Text(
                      'Pay Service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Work Photos ─────────────────────────────────
                      if ((booking?.workPhotoUrls ?? []).isNotEmpty) ...[
                        const Text(
                          'Work Photos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: booking!.workPhotoUrls.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () => _showPhotoViewer(
                                    context, booking.workPhotoUrls, i),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    booking.workPhotoUrls[i],
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) =>
                                        progress == null
                                            ? child
                                            : Container(
                                                width: 110,
                                                height: 110,
                                                color:
                                                    const Color(0xFFF1F5F9),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                ),
                                              ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Bill Details ────────────────────────────────
                      const Text(
                        'Bill Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _BillRow(
                              label: 'Diagnose fee',
                              value: _rp(diagnoseFee),
                            ),
                            const SizedBox(height: 10),
                            _BillRow(
                              label: 'Visit fee',
                              value: _rp(visitFee > 0 ? visitFee : 0),
                            ),
                            const Divider(height: 24, color: Color(0xFFF1F5F9)),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Bill',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  _rp(finalTotal),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0061FF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Payment Methods ────────────────────────────
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _PaymentMethodSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // ── Confirm Payment Button ──────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SafeArea(
                  top: false,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () => controller.confirmPayment(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Confirm Payment Received',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
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

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  const _BillRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  SELECTABLE PAYMENT METHOD SECTION
// ─────────────────────────────────────────────────────────────────
class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection();

  @override
  Widget build(BuildContext context) {
    // Only Cash is available — other methods are not yet integrated
    return _SelectableTile(
      icon: Icons.payments_outlined,
      iconColor: const Color(0xFF16A34A),
      title: 'Cash',
      subtitle: 'Pay directly to the technician',
      selected: true,
      onTap: () {},
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  SELECTABLE TILE
// ─────────────────────────────────────────────────────────────────
class _SelectableTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool selected;
  final bool comingSoon;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF0061FF)
                : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (comingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Soon',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF0061FF), size: 22)
            else
              const Icon(Icons.radio_button_unchecked_rounded,
                  color: Color(0xFFCBD5E1), size: 22),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _EWalletBadge extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool comingSoon;
  final bool selected;

  const _EWalletBadge({
    required this.label,
    required this.color,
    required this.onTap,
    this.comingSoon = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: comingSoon
                      ? color.withValues(alpha: 0.35)
                      : color,
                  borderRadius: BorderRadius.circular(14),
                  border: selected
                      ? Border.all(color: const Color(0xFF0061FF), width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    label.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (comingSoon)
                Positioned(
                  top: -6, right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Soon',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: comingSoon
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

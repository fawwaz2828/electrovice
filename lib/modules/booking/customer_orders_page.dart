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
          final activeOrders = controller.bookingHistory
              .where((b) => b.isActive)
              .toList();

          final doneOrders = controller.bookingHistory
              .where((b) => b.status == BookingStatus.done)
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
                        'Pesanan Aktif',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeOrders.isEmpty
                            ? 'Tidak ada pesanan berjalan'
                            : '${activeOrders.length} pesanan sedang berjalan',
                        style: const TextStyle(
                            color: Color(0xFF68738A), fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (activeOrders.isEmpty && doneOrders.isEmpty)
                const SliverFillRemaining(
                    hasScrollBody: false, child: _EmptyOrdersState()),
              if (activeOrders.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
              if (doneOrders.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        const Text(
                          'Riwayat',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 8),
                        if (doneOrders.any((b) => b.customerRating == null))
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${doneOrders.where((b) => b.customerRating == null).length} belum direview',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DoneOrderCard(booking: doneOrders[i]),
                      ),
                      childCount: doneOrders.length,
                    ),
                  ),
                ),
              ],
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
                      : 'Diskusi di lokasi',
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
        BookingStatus.pending => (const Color(0xFF6B7280), 'MENUNGGU'),
        BookingStatus.confirmed => (const Color(0xFF3B82F6), 'DIKONFIRMASI'),
        BookingStatus.onProgress => (const Color(0xFFF59E0B), 'DIKERJAKAN'),
        BookingStatus.awaitingPayment => (const Color(0xFF10B981), 'BAYAR'),
        _ => (const Color(0xFF6B7280), status.toUpperCase()),
      };

  IconData _categoryIcon(String category) => switch (category) {
        'vehicle' => Icons.two_wheeler_rounded,
        _ => Icons.devices_rounded,
      };

  String _damageTypeLabel(String type) => switch (type) {
        'screen' => 'Kerusakan Layar',
        'battery' => 'Masalah Baterai',
        'hardware' => 'Kerusakan Hardware',
        'water' => 'Water Damage',
        'camera' => 'Masalah Kamera',
        _ => 'Perbaikan Umum',
      };

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
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

// ── Done Order Card (Riwayat) ──────────────────────────────────────────────
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
                      'TULIS ULASAN',
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
                          : 'Selesai',
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
        'screen' => 'Kerusakan Layar',
        'battery' => 'Masalah Baterai',
        'hardware' => 'Kerusakan Hardware',
        'water' => 'Water Damage',
        'camera' => 'Masalah Kamera',
        _ => 'Perbaikan Umum',
      };

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
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
            'Tidak ada pesanan aktif',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pesanan yang sedang berjalan\nakan tampil di sini',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9CA3AF), height: 1.5),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Get.offNamed(AppRoutes.home),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white),
            child: const Text('Cari Teknisi',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key});

  void _showPhotoViewer(
      BuildContext context, List<String> urls, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0A0A0A),
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
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
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

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _orderNumber(String bookingId) {
    final id = bookingId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    return 'EV-${id.substring(0, id.length.clamp(0, 6))}';
  }

  String _damageLabel(String type) => switch (type) {
        'screen' => 'Screen Replacement',
        'battery' => 'Battery Replacement',
        'hardware' => 'Hardware Repair',
        'water' => 'Water Damage Recovery',
        'camera' => 'Camera Repair',
        _ => 'General Repair',
      };

  @override
  Widget build(BuildContext context) {
    final booking = Get.arguments as BookingDocument?;
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Detail')),
        body: const Center(child: Text('Data not found')),
      );
    }

    // Tampilkan review button hanya jika yang membuka adalah customer dari booking ini
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isCustomerView = currentUid == booking.userId;

    final diagnoseFee = booking.estimatedPrice;
    final serviceFee = booking.finalServiceFee ?? 0;
    final spareParts = booking.finalSpareParts;
    final total = booking.finalTotalAmount ?? diagnoseFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF0A0A0A)),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    'Order Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Order Header Card ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order number badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ORDER #${_orderNumber(booking.bookingId)}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4163FF),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            booking.serviceName.isNotEmpty ? booking.serviceName : _damageLabel(booking.damageType),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.description.isNotEmpty
                                ? booking.description
                                : 'Repair service by ${booking.technicianName}.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                          if (booking.finalNote != null &&
                              booking.finalNote!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFF8F9FB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.notes_rounded,
                                      size: 16, color: Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      booking.finalNote!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF475569),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Invoice Details Card ───────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Invoice header
                          Row(
                            children: [
                              const Icon(Icons.receipt_long_outlined,
                                  size: 20, color: Color(0xFF4163FF)),
                              const SizedBox(width: 8),
                              const Text(
                                'Invoice Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0A0A0A),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(booking.updatedAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Spare parts section
                          if (spareParts.isNotEmpty) ...[
                            const _SectionLabel(label: 'ITEMIZED PARTS'),
                            const SizedBox(height: 10),
                            ...spareParts.map((part) {
                              final name = part['name'] as String? ?? '-';
                              final price =
                                  (part['price'] as num?)?.toInt() ?? 0;
                              return _InvoiceRow(
                                  label: name, value: _rp(price));
                            }),
                            const SizedBox(height: 16),
                          ],

                          // Service & labor section
                          const _SectionLabel(label: 'SERVICE & LABOR'),
                          const SizedBox(height: 10),
                          _InvoiceRow(
                            label: 'Diagnostic & Inspection Fee',
                            value: _rp(diagnoseFee),
                          ),
                          if (serviceFee > 0) ...[
                            const SizedBox(height: 6),
                            _InvoiceRow(
                              label: 'Service Fee',
                              value: _rp(serviceFee),
                            ),
                          ],

                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 16),

                          // Total paid
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TOTAL PAID',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF4163FF),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _rp(total),
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0061FF),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Color(0xFFCBD5E1), size: 18),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'PAYMENT\nSUCCESS',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFCBD5E1),
                                      letterSpacing: 0.4,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // ── Work Photos ────────────────────────────────────
                    if (booking.workPhotoUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.photo_library_outlined,
                                    size: 18, color: Color(0xFF4163FF)),
                                const SizedBox(width: 8),
                                const Text(
                                  'Work Proof Photos',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0A0A0A),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${booking.workPhotoUrls.length} photo(s)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: booking.workPhotoUrls.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (ctx, i) {
                                  return GestureDetector(
                                    onTap: () => _showPhotoViewer(
                                        ctx, booking.workPhotoUrls, i),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        booking.workPhotoUrls[i],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (_, child, prog) =>
                                            prog == null
                                                ? child
                                                : Container(
                                                    width: 100,
                                                    height: 100,
                                                    color: const Color(
                                                        0xFFE2E8F0),
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
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // ── Technician info ────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Color(0xFFDCE7FB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: booking.technicianPhotoUrl != null &&
                                    booking.technicianPhotoUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                        booking.technicianPhotoUrl!,
                                        fit: BoxFit.cover),
                                  )
                                : const Icon(Icons.person_rounded,
                                    color: Color(0xFF4163FF), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.technicianName,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  booking.category.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          if (booking.customerRating != null) ...[
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFBBF24), size: 16),
                            const SizedBox(width: 3),
                            Text(
                              '${booking.customerRating}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Action Buttons ─────────────────────────────────
                    // Download PDF — display only (no PDF yet)
                    OutlinedButton.icon(
                      onPressed: () => Get.snackbar(
                        'Coming soon',
                        'PDF invoice will be available soon',
                        snackPosition: SnackPosition.TOP,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF0A0A0A)),
                        backgroundColor: Color(0xFF0A0A0A),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text(
                        'Download PDF Invoice',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Get.snackbar(
                        'Coming soon',
                        'Share feature will be available soon',
                        snackPosition: SnackPosition.TOP,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      icon: const Icon(Icons.share_rounded,
                          size: 18, color: Color(0xFF475569)),
                      label: const Text(
                        'Share Digital Record',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),

                    // Review button — hanya untuk customer, bukan teknisi
                    if (isCustomerView &&
                        booking.status == BookingStatus.done &&
                        booking.customerRating == null) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            Get.toNamed(AppRoutes.review, arguments: booking),
                        style: FilledButton.styleFrom(
                          backgroundColor: Color(0xFF4163FF),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.star_outline_rounded, size: 18),
                        label: const Text(
                          'Write a Review',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  const _InvoiceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0A0A),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';

class JobSummaryPage extends StatelessWidget {
  const JobSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingDocument? order = Get.arguments is BookingDocument
        ? Get.arguments as BookingDocument
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // ── Ikon sukses ──────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF0061FF),
                  size: 60,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Pekerjaan Selesai!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                order != null
                    ? 'Servis untuk ${order.userName} telah\nberhasil diselesaikan.'
                    : 'Layanan kamu telah berhasil diselesaikan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // ── Summary card ─────────────────────────────────────
              if (order != null) _SummaryCard(order: order),

              const Spacer(),

              // ── CTA ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.technicianHome),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'KEMBALI KE BERANDA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary Card ───────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final BookingDocument order;
  const _SummaryCard({required this.order});

  String _damageLabel(String type) => switch (type) {
        'screen' => 'Kerusakan Layar',
        'battery' => 'Masalah Baterai',
        'hardware' => 'Kerusakan Hardware',
        'water' => 'Water Damage',
        'camera' => 'Masalah Kamera',
        _ => 'Perbaikan Umum',
      };

  String _formatRp(int price) {
    if (price <= 0) return 'Tunai (diskusi)';
    final s = price.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Ags','Sep','Okt','Nov','Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // ── Header: customer name + kategori ─────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE7FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Color(0xFF3654FF), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.userName,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      order.category.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SELESAI',
                  style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w800,
                      fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),

          // ── Detail rows ───────────────────────────────────────
          _Row(
            label: 'Jenis Kerusakan',
            value: _damageLabel(order.damageType),
          ),
          const SizedBox(height: 12),
          _Row(
            label: 'Alamat',
            value: order.userAddress.isNotEmpty
                ? order.userAddress
                : 'Tidak dicatat',
          ),
          const SizedBox(height: 12),
          _Row(
            label: 'Waktu Selesai',
            value: _formatDate(order.updatedAt),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),

          // ── Total biaya ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ESTIMASI BIAYA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                _formatRp(order.estimatedPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0061FF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Metode pembayaran ─────────────────────────────────
          _Row(
            label: 'Pembayaran',
            value: order.paymentMethod == PaymentMethod.cash
                ? 'Tunai'
                : order.paymentMethod.toUpperCase(),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(' : ',
            style: TextStyle(color: Color(0xFF94A3B8))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';
import '../../services/booking_service.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late final BookingDocument _booking;
  final _reviewCtrl = TextEditingController();
  int _selectedRating = 5;
  bool _recommend = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is BookingDocument) {
      _booking = args;
    } else {
      Get.back();
      return;
    }
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await BookingService().submitReview(
        bookingId: _booking.bookingId,
        technicianId: _booking.technicianId,
        rating: _selectedRating,
        review: _reviewCtrl.text.trim(),
        recommend: _recommend,
      );
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar(
        'Terima Kasih!',
        'Ulasan kamu sudah tersimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22C55E),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 16, 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    'Beri Ulasan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    // ── Technician summary ─────────────────────
                    _TechCard(booking: _booking),
                    const SizedBox(height: 20),

                    // ── Star rating ────────────────────────────
                    _StarRatingCard(
                      selected: _selectedRating,
                      onChanged: (v) => setState(() => _selectedRating = v),
                    ),
                    const SizedBox(height: 16),

                    // ── Review text ────────────────────────────
                    _ReviewTextField(controller: _reviewCtrl),
                    const SizedBox(height: 16),

                    // ── Tags quick-pick ────────────────────────
                    _QuickTagsRow(
                      onTap: (tag) {
                        final cur = _reviewCtrl.text.trim();
                        _reviewCtrl.text =
                            cur.isEmpty ? tag : '$cur, $tag';
                        _reviewCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: _reviewCtrl.text.length),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Recommend toggle ───────────────────────
                    _RecommendToggle(
                      value: _recommend,
                      onChanged: (v) => setState(() => _recommend = v),
                    ),
                  ],
                ),
              ),
            ),

            // ── CTA ─────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('SUBMIT FEEDBACK',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.home),
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

// ── Tech Card ──────────────────────────────────────────────────────────────
class _TechCard extends StatelessWidget {
  final BookingDocument booking;
  const _TechCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: booking.technicianPhotoUrl != null &&
                    booking.technicianPhotoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(booking.technicianPhotoUrl!,
                        fit: BoxFit.cover),
                  )
                : const Icon(Icons.person_rounded, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.technicianName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  booking.category.toUpperCase(),
                  style: const TextStyle(
                      color: Color(0xFF727B8B), fontSize: 13),
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
    );
  }
}

// ── Star Rating Card ───────────────────────────────────────────────────────
class _StarRatingCard extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _StarRatingCard({required this.selected, required this.onChanged});

  static const _labels = ['Sangat Buruk', 'Buruk', 'Cukup', 'Bagus', 'Luar Biasa!'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          const Text(
            'Seberapa puas kamu dengan layanan teknisi?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => onChanged(star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    star <= selected
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 40,
                    color: star <= selected
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            _labels[selected - 1],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: selected >= 4
                  ? const Color(0xFF10B981)
                  : selected == 3
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review Text Field ──────────────────────────────────────────────────────
class _ReviewTextField extends StatelessWidget {
  final TextEditingController controller;
  const _ReviewTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CERITAKAN PENGALAMANMU',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5D6780),
                letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 500,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  'Contoh: Teknisi datang tepat waktu, pekerjaan rapi dan cepat...',
              hintStyle: const TextStyle(color: Color(0xFFB7C0D2)),
              filled: true,
              fillColor: const Color(0xFFF5F7FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recommend Toggle ───────────────────────────────────────────────────────
class _RecommendToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _RecommendToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasikan teknisi ini?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Bantu pengguna lain dengan rekomendasimu',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4163FF),
            activeTrackColor: const Color(0xFFBFCBFF),
          ),
        ],
      ),
    );
  }
}

// ── Quick Tags ─────────────────────────────────────────────────────────────
class _QuickTagsRow extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _QuickTagsRow({required this.onTap});

  static const _tags = [
    'Tepat waktu',
    'Ramah',
    'Hasil rapi',
    'Harga sesuai',
    'Profesional',
    'Cepat selesai',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Pilih yang sesuai:',
            style: TextStyle(
                color: Color(0xFF5D6780),
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags
              .map((tag) => GestureDetector(
                    onTap: () => onTap(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD1D9E6)),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

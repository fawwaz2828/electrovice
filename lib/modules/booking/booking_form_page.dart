import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import 'booking_controller.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const Color _bg   = Color(0xFFF2F3F7);
const Color _card = Colors.white;
const Color _ink  = Color(0xFF0F172A);
const Color _muted= Color(0xFF64748B);
const Color _blue = Color(0xFF0061FF);

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  late final BookingController _ctrl;
  final _addressCtrl = TextEditingController();
  final _notesCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<BookingController>();
    // Pre-fill address if already set
    if (_ctrl.userAddress.value.isNotEmpty) {
      _addressCtrl.text = _ctrl.userAddress.value;
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_addressCtrl.text.trim().isEmpty) {
      Get.snackbar('Alamat belum diisi', 'Masukkan alamat lengkap kamu',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    _ctrl.setUserAddress(_addressCtrl.text.trim());
    _ctrl.setDescription(_notesCtrl.text.trim());
    Get.toNamed(AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            Container(
              color: _card,
              padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: _ink),
                  ),
                  const Expanded(
                    child: Text(
                      'Atur Jadwal',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Selected service summary ──────────────────────
                    _SelectedServiceCard(ctrl: _ctrl),
                    const SizedBox(height: 14),

                    // ── 2. Jadwal ────────────────────────────────────────
                    _SectionLabel(label: 'JADWAL KUNJUNGAN'),
                    const SizedBox(height: 10),
                    _ScheduleCard(ctrl: _ctrl),
                    const SizedBox(height: 14),

                    // ── 3. Alamat ────────────────────────────────────────
                    _SectionLabel(label: 'ALAMAT LENGKAP'),
                    const SizedBox(height: 10),
                    _AddressCard(controller: _addressCtrl, ctrl: _ctrl),
                    const SizedBox(height: 14),

                    // ── 4. Catatan + Foto kerusakan ──────────────────────
                    _SectionLabel(label: 'CATATAN & FOTO KERUSAKAN (OPSIONAL)'),
                    const SizedBox(height: 10),
                    _NotesAndPhotosCard(notesController: _notesCtrl, ctrl: _ctrl),
                    const SizedBox(height: 14),

                    // ── Security note ────────────────────────────────────
                    _SecurityNote(),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ─────────────────────────────────────────────
            Container(
              color: _card,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: SafeArea(
                top: false,
                child: FilledButton.icon(
                  onPressed: _onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: _ink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'Lanjut ke Checkout',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: _muted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ── Selected service summary card ────────────────────────────────────────────
class _SelectedServiceCard extends StatelessWidget {
  final BookingController ctrl;
  const _SelectedServiceCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tech = ctrl.selectedTechnician.value;
      final svc  = ctrl.selectedService.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: tech?.photoUrl != null && tech!.photoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(tech.photoUrl!, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.person_rounded,
                      color: _blue, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tech?.name ?? '-',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  if (svc != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      svc.service,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _blue,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Price
            if (svc != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    svc.priceLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                  Text(
                    svc.durationLabel,
                    style: const TextStyle(fontSize: 10, color: _muted),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}

// ── Schedule card ──────────────────────────────────────────────────────────────
class _ScheduleCard extends StatelessWidget {
  final BookingController ctrl;
  const _ScheduleCard({required this.ctrl});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
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
          // ── Date row ─────────────────────────────────────────────
          Obx(() {
            final dt = ctrl.scheduledAt.value;
            final label =
                '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
            return GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dt,
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 30)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: _blue,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) ctrl.setScheduledDate(picked);
              },
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: _blue, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TANGGAL KUNJUNGAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _muted,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ubah',
                      style: TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // ── Time slots ───────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: _muted, size: 16),
              const SizedBox(width: 8),
              const Text(
                'PILIH JAM',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Obx(() => ctrl.isLoadingSlots.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _blue))
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 10),

          Obx(() {
            final slots    = ctrl.allDaySlots;
            final selected = ctrl.scheduledAt.value;

            if (slots.isEmpty) {
              return const Text(
                'Tidak ada slot tersedia',
                style: TextStyle(color: _muted, fontSize: 13),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final isAvailable = ctrl.isSlotAvailable(slot);
                final isSelected  = slot.hour == selected.hour &&
                    slot.day  == selected.day  &&
                    slot.month == selected.month &&
                    slot.year == selected.year;
                final range =
                    '${slot.hour.toString().padLeft(2, '0')}.00 – '
                    '${(slot.hour + 2).toString().padLeft(2, '0')}.00';

                Color bg, fg, border;
                if (!isAvailable) {
                  bg = const Color(0xFFF5F5F5);
                  fg = const Color(0xFFBDBDBD);
                  border = const Color(0xFFEEEEEE);
                } else if (isSelected) {
                  bg = _ink;
                  fg = Colors.white;
                  border = _ink;
                } else {
                  bg = _card;
                  fg = _ink;
                  border = const Color(0xFFD1D9E6);
                }

                return GestureDetector(
                  onTap: !isAvailable
                      ? null
                      : () => ctrl.setScheduledAt(DateTime(
                            selected.year,
                            selected.month,
                            selected.day,
                            slot.hour,
                          )),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          range,
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        if (!isAvailable)
                          Text(
                            'Penuh',
                            style: TextStyle(
                              color: fg,
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 8),
          const Text(
            '* Jam kerja 08.00 – 17.00 • Tiap slot 2 jam',
            style: TextStyle(color: _muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ── Address card ──────────────────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final TextEditingController controller;
  final BookingController ctrl;
  const _AddressCard({required this.controller, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
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
          // ── Label ──────────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: _blue),
              SizedBox(width: 8),
              Text(
                'ALAMAT PENJEMPUTAN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Text field alamat ───────────────────────────────────
          TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: _ink),
            decoration: InputDecoration(
              hintText:
                  'Contoh: Jl. Sudirman No. 12, RT 03/RW 05, Menteng, Jakarta Pusat',
              hintStyle: TextStyle(
                  color: _muted.withValues(alpha: 0.7), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),

          // ── Map picker button ───────────────────────────────────
          Obx(() {
            final hasPin = ctrl.latitude.value != null;
            return GestureDetector(
              onTap: () => ctrl.pickLocationFromMap((addr) {
                controller.text = addr;
              }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: hasPin
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasPin
                        ? _blue.withValues(alpha: 0.4)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasPin
                          ? Icons.location_on_rounded
                          : Icons.add_location_alt_rounded,
                      color: hasPin ? _blue : _muted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hasPin
                            ? '${ctrl.latitude.value!.toStringAsFixed(6)}, '
                                '${ctrl.longitude.value!.toStringAsFixed(6)}'
                            : 'Pilih lokasi di peta',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasPin ? _blue : _muted,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: _muted, size: 20),
                  ],
                ),
              ),
            );
          }),

          // ── Konfirmasi pin ─────────────────────────────────────
          Obx(() {
            if (ctrl.latitude.value == null) return const SizedBox.shrink();
            return const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 14, color: Color(0xFF16A34A)),
                  SizedBox(width: 6),
                  Text(
                    'Koordinat tersimpan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Notes + Photos card ────────────────────────────────────────────────────────
class _NotesAndPhotosCard extends StatelessWidget {
  final TextEditingController notesController;
  final BookingController ctrl;
  const _NotesAndPhotosCard(
      {required this.notesController, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
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
          // ── Text area ───────────────────────────────────────────
          TextField(
            controller: notesController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: _ink),
            decoration: InputDecoration(
              hintText:
                  'Contoh: Layar HP retak setelah jatuh, ada garis hitam di kiri...',
              hintStyle:
                  TextStyle(color: _muted.withValues(alpha: 0.7), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 14),
          // ── Photo section label ──────────────────────────────────
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, size: 15, color: _muted),
              const SizedBox(width: 6),
              const Text(
                'FOTO KERUSAKAN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Obx(() => Text(
                    '${ctrl.damagePhotos.length}/3',
                    style: const TextStyle(fontSize: 11, color: _muted),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          // ── Photo tiles ──────────────────────────────────────────
          Obx(() {
            final photos = ctrl.damagePhotos;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Existing photos
                ...List.generate(photos.length, (i) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          photos[i],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => ctrl.removeDamagePhoto(i),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                // Add button (max 3)
                if (photos.length < 3)
                  GestureDetector(
                    onTap: ctrl.addDamagePhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFD1D9E6),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              size: 22, color: _muted),
                          SizedBox(height: 4),
                          Text(
                            'Tambah',
                            style: TextStyle(fontSize: 10, color: _muted),
                          ),
                        ],
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

// ── Security note ─────────────────────────────────────────────────────────────
class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFD7FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 20, color: _blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kode verifikasi 6 digit akan digenerate setelah konfirmasi. Tunjukkan kode ini hanya kepada teknisi saat tiba di lokasi.',
              style: TextStyle(
                color: Color(0xFF1D4ED8),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

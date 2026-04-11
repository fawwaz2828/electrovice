import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import 'booking_controller.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  late final BookingController _ctrl;
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _selectedDamage = 'other';

  static const Color _bg = Color(0xFFF7F8FC);

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<BookingController>();
    _selectedDamage = _ctrl.damageType.value;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_descCtrl.text.trim().isEmpty) {
      Get.snackbar('Oops', 'Deskripsikan keluhan perangkat kamu dulu',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      Get.snackbar('Oops', 'Masukkan alamat lengkap kamu',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    _ctrl.setDescription(_descCtrl.text.trim());
    _ctrl.setDamageType(_selectedDamage);
    _ctrl.setUserAddress(_addressCtrl.text.trim());
    Get.toNamed(AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Text(
                    'Buat Pesanan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Technician Info Card ─────────────────────────────
                    _TechnicianHeaderCard(ctrl: _ctrl),
                    const SizedBox(height: 20),

                    // ── 1. Damage Type ───────────────────────────────────
                    const _StepHeader(title: '1. JENIS KERUSAKAN', trailing: 'Wajib'),
                    const SizedBox(height: 12),
                    _DamageGrid(
                      selected: _selectedDamage,
                      onSelect: (type) => setState(() => _selectedDamage = type),
                    ),
                    const SizedBox(height: 16),

                    // ── 2. Deskripsi ─────────────────────────────────────
                    const _StepHeader(title: '2. DESKRIPSI KELUHAN'),
                    const SizedBox(height: 12),
                    _NotesCard(controller: _descCtrl),
                    const SizedBox(height: 20),

                    // ── 3. Alamat ─────────────────────────────────────────
                    const _StepHeader(title: '3. ALAMAT LENGKAP', trailing: 'Wajib'),
                    const SizedBox(height: 12),
                    _AddressCard(controller: _addressCtrl, ctrl: _ctrl),
                    const SizedBox(height: 20),

                    // ── 4. Jadwal ────────────────────────────────────────
                    const _StepHeader(title: '4. JADWAL SERVIS'),
                    const SizedBox(height: 12),
                    _ScheduleCard(ctrl: _ctrl),
                    const SizedBox(height: 16),

                    // ── Harga estimasi ───────────────────────────────────
                    _PriceEstimateCard(ctrl: _ctrl),
                    const SizedBox(height: 16),

                    // ── Security notice ──────────────────────────────────
                    const _SecurityNoticeCard(),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ───────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: SafeArea(
                top: false,
                child: FilledButton(
                  onPressed: _onConfirm,
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
                      Text('KONFIRMASI & PESAN',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded),
                    ],
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

// ── Technician Header Card ─────────────────────────────────────────────────
class _TechnicianHeaderCard extends StatelessWidget {
  final BookingController ctrl;
  const _TechnicianHeaderCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = ctrl.selectedTechnician.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE7FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: t?.photoUrl != null && t!.photoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(t.photoUrl!, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.person_rounded, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t?.name ?? '-',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t?.specialty.isEmpty ?? true
                        ? (t?.category ?? '-').toUpperCase()
                        : t!.specialty,
                    style: const TextStyle(
                        color: Color(0xFF727B8B), fontSize: 13),
                  ),
                ],
              ),
            ),
            if (t != null && t.rating > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      t.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ── Step Header ────────────────────────────────────────────────────────────
class _StepHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  const _StepHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF5D6780),
            letterSpacing: 1.0,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(trailing!,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF3654FF))),
      ],
    );
  }
}

// ── Damage Grid ────────────────────────────────────────────────────────────
class _DamageGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _DamageGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const items = <(String, IconData, String)>[
      ('screen', Icons.screenshot_monitor_outlined, 'Layar'),
      ('battery', Icons.battery_4_bar_rounded, 'Baterai'),
      ('hardware', Icons.memory_rounded, 'Hardware'),
      ('water', Icons.water_drop_outlined, 'Air'),
      ('camera', Icons.camera_alt_outlined, 'Kamera'),
      ('other', Icons.more_horiz_rounded, 'Lainnya'),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        final isSelected = item.$1 == selected;
        return GestureDetector(
          onTap: () => onSelect(item.$1),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFE5E9F2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2,
                    color: isSelected ? Colors.white : Colors.black),
                const SizedBox(height: 6),
                Text(
                  item.$3,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Notes Card ─────────────────────────────────────────────────────────────
class _NotesCard extends StatelessWidget {
  final TextEditingController controller;
  const _NotesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 18, color: Color(0xFF6B7487)),
              SizedBox(width: 8),
              Text(
                'DESKRIPSI KELUHAN',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: Color(0xFF5D6780)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  'Contoh: Layar HP retak setelah jatuh, ada garis hitam di kiri...',
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

// ── Address Card ───────────────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final TextEditingController controller;
  final BookingController ctrl;
  const _AddressCard({required this.controller, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
<<<<<<< HEAD
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
=======
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
              separatorBuilder: (_, _) => const SizedBox(width: 10),
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
              separatorBuilder: (_, _) => const SizedBox(width: 10),
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
>>>>>>> origin/main
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6B7487)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ALAMAT PENJEMPUTAN',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF5D6780)),
                ),
              ),
              // Tombol deteksi GPS
              Obx(() => GestureDetector(
                onTap: ctrl.isDetectingLocation.value ? null : ctrl.detectGpsLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ctrl.latitude.value != null
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ctrl.latitude.value != null
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3654FF),
                      width: 1,
                    ),
                  ),
                  child: ctrl.isDetectingLocation.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ctrl.latitude.value != null
                                  ? Icons.check_circle_rounded
                                  : Icons.my_location_rounded,
                              size: 14,
                              color: ctrl.latitude.value != null
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF3654FF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ctrl.latitude.value != null ? 'GPS ✓' : 'GPS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ctrl.latitude.value != null
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF3654FF),
                              ),
                            ),
                          ],
                        ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Contoh: Jl. Sudirman No. 12, RT 03/RW 05, Kel. Menteng, Jakarta Pusat',
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
          Obx(() {
            if (ctrl.latitude.value == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed_rounded, size: 13, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text(
                    'Koordinat GPS tersimpan: ${ctrl.latitude.value!.toStringAsFixed(5)}, ${ctrl.longitude.value!.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF10B981)),
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

// ── Schedule Card ──────────────────────────────────────────────────────────
class _ScheduleCard extends StatelessWidget {
  final BookingController ctrl;
  const _ScheduleCard({required this.ctrl});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _monthName(int m) => _months[m - 1];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Baris tanggal ─────────────────────────────────────
          Obx(() {
            final date = ctrl.scheduledAt.value;
            return GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF3654FF),
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
                      color: Color(0xFF3654FF), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TANGGAL KUNJUNGAN',
                          style: TextStyle(
                            color: Color(0xFF5D6780),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${date.day} ${_monthName(date.month)} ${date.year}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ubah',
                      style: TextStyle(
                        color: Color(0xFF3654FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEFF1F7)),
          const SizedBox(height: 14),

          // ── Label jam ─────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: Color(0xFF5D6780), size: 16),
              const SizedBox(width: 6),
              const Text(
                'PILIH JAM SERVIS',
                style: TextStyle(
                  color: Color(0xFF5D6780),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Obx(() => ctrl.isLoadingSlots.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 10),

          // ── Chips jam ─────────────────────────────────────────
          Obx(() {
            final slots = ctrl.allDaySlots;
            final selected = ctrl.scheduledAt.value;

            if (slots.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tidak ada slot tersedia',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final isAvailable = ctrl.isSlotAvailable(slot);
                final isSelected = slot.hour == selected.hour &&
                    slot.day == selected.day &&
                    slot.month == selected.month &&
                    slot.year == selected.year;
                final hourStr =
                    '${slot.hour.toString().padLeft(2, '0')}.00';
                final endHour = slot.hour + 2;
                final rangeStr =
                    '$hourStr – ${endHour.toString().padLeft(2, '0')}.00';

                Color bg;
                Color textColor;
                Color borderColor;

                if (!isAvailable) {
                  bg = const Color(0xFFF5F5F5);
                  textColor = const Color(0xFFBDBDBD);
                  borderColor = const Color(0xFFEEEEEE);
                } else if (isSelected) {
                  bg = Colors.black;
                  textColor = Colors.white;
                  borderColor = Colors.black;
                } else {
                  bg = Colors.white;
                  textColor = Colors.black;
                  borderColor = const Color(0xFFD1D9E6);
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
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          rangeStr,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (!isAvailable)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Penuh',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 6),
          const Text(
            '* Jam kerja 08.00 – 17.00 • Tiap slot 2 jam',
            style: TextStyle(color: Color(0xFF99A2B5), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Price Estimate Card ────────────────────────────────────────────────────
class _PriceEstimateCard extends StatelessWidget {
  final BookingController ctrl;
  const _PriceEstimateCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final estimates = ctrl.selectedTechnician.value?.serviceEstimates ?? [];
      if (estimates.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ESTIMASI BIAYA',
              style: TextStyle(
                color: Color(0xFF5D6780),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ...estimates.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e.service,
                            style:
                                const TextStyle(color: Color(0xFF5F6778))),
                      ),
                      Text(
                        e.priceLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '* Harga final ditentukan setelah diagnosa',
                style: TextStyle(color: Color(0xFF99A2B5), fontSize: 11),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Security Notice ────────────────────────────────────────────────────────
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
              'Kode verifikasi 6 digit akan digenerate setelah konfirmasi. Tunjukkan kode ini hanya kepada teknisi saat tiba di lokasi.',
              style: TextStyle(color: Color(0xFF365081), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

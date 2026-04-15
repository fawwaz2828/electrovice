import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';
import '../notification/notification_controller.dart';
import 'technician_controller.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _ActiveJobCard extends StatelessWidget {
  final String title;
  final String customerName;
  final String status;
  final VoidCallback onTap;
  const _ActiveJobCard({
    required this.title,
    required this.customerName,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == BookingStatus.confirmed;
    final bgColor = isConfirmed ? const Color(0xFF1E293B) : const Color(0xFF0061FF);
    final statusLabel = isConfirmed ? 'MENUJU LOKASI' : 'SEDANG DIKERJAKAN';
    final buttonLabel = isConfirmed ? 'INPUT KODE VERIFIKASI' : 'LIHAT PEKERJAAN';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConfirmed ? Icons.directions_walk_rounded : Icons.bolt_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'PEKERJAAN AKTIF',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: $customerName',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  final TechnicianController _controller = Get.find<TechnicianController>();
  _FilterTab _selectedFilter = _FilterTab.newOrders;

  String _damageLabel(String type) => switch (type) {
        'screen' => 'Kerusakan Layar',
        'battery' => 'Masalah Baterai',
        'hardware' => 'Kerusakan Hardware',
        'water' => 'Water Damage',
        'camera' => 'Masalah Kamera',
        _ => 'Perbaikan Umum',
      };

  String _formatSchedule(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      extendBody: true,
      bottomNavigationBar: const TechnicianNavBar(
        selectedItem: AppNavItem.home,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Header ───────────────────────────────────────────────
              Obx(() => _Header(
                isOnline: _controller.isOnline.value, 
                onToggle: (v) => _controller.isOnline.value = v,
                name: _controller.profile.value?.fullName.split(' ').first ?? 'Technician',
              )),

              const SizedBox(height: 20),

              // ── Earnings Card ─────────────────────────────────────────
              const _EarningsCard(),

              const SizedBox(height: 14),

              // ── Orders Completed Card ─────────────────────────────────
              const _OrdersCompletedCard(),

              const SizedBox(height: 28),

              Obx(() {
                final activeOrder = _controller.activeOrder.value;
                final pendingOrders = _controller.incomingOrders
                    .where((o) => o.status == BookingStatus.pending)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Current Assignment (confirmed atau on_progress) ────────
                    if (activeOrder != null) ...[
                      const Text(
                        'Pekerjaan Aktif',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ActiveJobCard(
                        title: _damageLabel(activeOrder.damageType),
                        customerName: activeOrder.userName,
                        status: activeOrder.status,
                        onTap: () {
                          _controller.selectOrder(activeOrder);
                          // Confirmed → belum verif kode → ke verification
                          // OnProgress → sudah verif → ke active job
                          if (activeOrder.status == BookingStatus.confirmed) {
                            Get.toNamed(AppRoutes.verification);
                          } else {
                            Get.toNamed(AppRoutes.activeJob);
                          }
                        },
                      ),
                      // Tetap tampilkan incoming requests di bawah jika ada
                      if (pendingOrders.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const Text(
                          'Permintaan Masuk',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...pendingOrders.map((order) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RequestCard(
                                category: order.category.toUpperCase(),
                                categoryColor: const Color(0xFF0061FF),
                                icon: Icons.build_rounded,
                                distance: _formatSchedule(order.scheduledAt),
                                title: _damageLabel(order.damageType),
                                description: order.description.isEmpty
                                    ? 'Tidak ada deskripsi tambahan'
                                    : order.description,
                                onTap: () {
                                  _controller.selectOrder(order);
                                  Get.toNamed(AppRoutes.jobDetail);
                                },
                              ),
                            )),
                      ],
                    ] else ...[
                      // ── Incoming Requests (hanya pending) ────────────────────
                      Row(
                        children: [
                          const Text(
                            'Permintaan Masuk',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          _FilterChip(
                            label: 'NEW',
                            selected: _selectedFilter == _FilterTab.newOrders,
                            onTap: () => setState(
                                () => _selectedFilter = _FilterTab.newOrders),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'ACTIVE',
                            selected: _selectedFilter == _FilterTab.activeOrders,
                            onTap: () => setState(
                                () => _selectedFilter = _FilterTab.activeOrders),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Builder(builder: (_) {
                        // NEW: pending orders yang bisa diambil
                        // ACTIVE: confirmed/on_progress/awaitingPayment
                        final displayOrders = _selectedFilter == _FilterTab.newOrders
                            ? pendingOrders
                            : _controller.incomingOrders
                                .where((o) =>
                                    o.status == BookingStatus.confirmed ||
                                    o.status == BookingStatus.onProgress ||
                                    o.status == BookingStatus.awaitingPayment)
                                .toList();

                        if (displayOrders.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                _selectedFilter == _FilterTab.newOrders
                                    ? 'Belum ada permintaan baru'
                                    : 'Tidak ada order aktif',
                                style: const TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: displayOrders.map((order) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RequestCard(
                                  category: order.category.toUpperCase(),
                                  categoryColor: _selectedFilter == _FilterTab.newOrders
                                      ? const Color(0xFF0061FF)
                                      : const Color(0xFF16A34A),
                                  icon: _selectedFilter == _FilterTab.newOrders
                                      ? Icons.build_rounded
                                      : Icons.bolt_rounded,
                                  distance: _formatSchedule(order.scheduledAt),
                                  title: _damageLabel(order.damageType),
                                  description: order.description.isEmpty
                                      ? 'Tidak ada deskripsi tambahan'
                                      : order.description,
                                  onTap: () {
                                    _controller.selectOrder(order);
                                    if (order.status == BookingStatus.pending) {
                                      Get.toNamed(AppRoutes.jobDetail);
                                    } else if (order.status == BookingStatus.confirmed) {
                                      Get.toNamed(AppRoutes.verification);
                                    } else {
                                      Get.toNamed(AppRoutes.activeJob);
                                    }
                                  },
                                ),
                              )).toList(),
                        );
                      }),
                    ],
                  ],
                );
              }), // Closes Obx

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  ENUM
// ─────────────────────────────────────────────────────────────────
enum _FilterTab { newOrders, activeOrders }

// ─────────────────────────────────────────────────────────────────
//  NOTIFICATION BELL (technician)
// ─────────────────────────────────────────────────────────────────
class _TechNotifBell extends StatelessWidget {
  _TechNotifBell();

  final _notifCtrl = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.notifications),
      child: Obx(() {
        final count = _notifCtrl.unreadCount.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF0F172A),
                size: 20,
              ),
            ),
            if (count > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

//  HEADER
// ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;
  final String name;
  const _Header({required this.isOnline, required this.onToggle, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            "Hello, $name!\nHere's Today's Summary",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.15,
            ),
          ),
        ),
        // ── Notification bell ──────────────────────────────────
        _TechNotifBell(),
        const SizedBox(width: 8),
        // ── Chat icon — ukuran padding sama dengan toggle agar rata ──
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.chatInbox),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // ── Online toggle ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'STATUS:\n${isOnline ? 'ONLINE' : 'OFFLINE'}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: isOnline
                      ? const Color(0xFF0061FF)
                      : const Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: isOnline,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF0061FF),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  EARNINGS CARD
// ─────────────────────────────────────────────────────────────────
class _EarningsCard extends StatelessWidget {
  const _EarningsCard();

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
    final ctrl = Get.find<TechnicianController>();
    return Obx(() {
      final earnings = ctrl.totalEarnings;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOTAL EARNINGS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _rp(earnings),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  '${ctrl.completedOrders.length} order selesai',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
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

// ─────────────────────────────────────────────────────────────────
//  ORDERS COMPLETED CARD
// ─────────────────────────────────────────────────────────────────
class _OrdersCompletedCard extends StatelessWidget {
  const _OrdersCompletedCard();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TechnicianController>();
    return Obx(() {
      final completed = ctrl.completedOrders.length;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ORDERS COMPLETED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    completed.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF16A34A),
                      height: 1.0,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completed == 0 ? 0.0 : (completed % 10) / 10.0,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF16A34A),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'TOTAL ALL TIME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFECFDF5),
                border: Border.all(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF16A34A),
                size: 20,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────
//  FILTER CHIP
// ─────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromARGB(255, 0, 0, 0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: selected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  REQUEST CARD
// ─────────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final String category;
  final Color categoryColor;
  final IconData icon;
  final String distance;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _RequestCard({
    required this.category,
    required this.categoryColor,
    required this.icon,
    required this.distance,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon column
          Column(
            children: [
              const SizedBox(height: 2),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF475569), size: 22),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Button
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'View\nDetails',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0061FF),
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

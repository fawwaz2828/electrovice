import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../services/technician_service.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      extendBody: true,
      bottomNavigationBar: const CustomerNavBar(selectedItem: AppNavItem.home),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => controller.loadNearbyTechnicians(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ELECTROVICE_LOGO_HD.png',
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
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
                              color: Color(0xFF1E293B),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() => Text(
                            'Hi, ${controller.userName.value.isEmpty ? 'there' : controller.userName.value}! 👋',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              height: 1.1,
                            ),
                          )),
                      const Text(
                        'Butuh bantuan perbaikan hari ini?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Hero CTA Card ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _HeroCTACard(),
                ),

                const SizedBox(height: 20),

                // ── Search Bar ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _SearchBar(),
                ),

                const SizedBox(height: 24),

                // ── Repair Categories ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const _RepairCategories(),
                ),

                const SizedBox(height: 28),

                // ── Nearby Technicians ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _NearbyTechniciansSection(),
                ),

                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HERO CTA CARD
// ═══════════════════════════════════════════════════════════════
class _HeroCTACard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.technicianList),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0061FF).withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Cari Teknisi\nTerdekat',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Elektronik & kendaraan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF93C5FD),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0061FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Lihat Semua →',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.handyman_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SEARCH BAR
// ═══════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.technicianList),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded,
                color: Color(0xFFADB5BD), size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Cari teknisi atau jenis perbaikan...',
                style: TextStyle(
                  color: Color(0xFFADB5BD),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  REPAIR CATEGORIES
// ═══════════════════════════════════════════════════════════════
class _RepairCategories extends StatelessWidget {
  const _RepairCategories();

  static const _categories = [
    {'icon': Icons.phone_android_rounded, 'label': 'HANDPHONE', 'category': 'electronic'},
    {'icon': Icons.laptop_rounded,        'label': 'KOMPUTER',  'category': 'electronic'},
    {'icon': Icons.tv_rounded,            'label': 'TV & AUDIO','category': 'electronic'},
    {'icon': Icons.kitchen_rounded,       'label': 'ELEKTRONIK','category': 'electronic'},
    {'icon': Icons.ac_unit_rounded,       'label': 'AC / KULKAS','category': 'electronic'},
    {'icon': Icons.directions_car_rounded,'label': 'KENDARAAN', 'category': 'vehicle'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kategori Layanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.technicianList),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0061FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2 baris × 3 kolom
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 0,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (_, i) {
              final c = _categories[i];
              return _CategoryItem(
                icon: c['icon'] as IconData,
                label: c['label'] as String,
                category: c['category'] as String,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String category;
  const _CategoryItem(
      {required this.icon, required this.label, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.technicianList,
        arguments: {'category': category},
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF475569), size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  NEARBY TECHNICIANS SECTION
// ═══════════════════════════════════════════════════════════════
class _NearbyTechniciansSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Teknisi Terdekat',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.technicianList),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0061FF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (controller.isLoadingTechnicians.value) {
            return Column(
              children: List.generate(
                2,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _TechnicianCardSkeleton(),
                ),
              ),
            );
          }

          if (controller.locationError.value.isNotEmpty) {
            return _ErrorState(
              message: controller.locationError.value,
              onRetry: controller.loadNearbyTechnicians,
            );
          }

          if (controller.nearbyTechnicians.isEmpty) {
            return _EmptyState(
              onExplore: () => Get.toNamed(AppRoutes.technicianList),
            );
          }

          return Column(
            children: controller.nearbyTechnicians
                .map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TechnicianCard(technician: t),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }
}

// ── Technician Card ────────────────────────────────────────────
class _TechnicianCard extends StatelessWidget {
  final TechnicianOnlineModel technician;
  const _TechnicianCard({required this.technician});

  @override
  Widget build(BuildContext context) {
    final priceLabel = technician.serviceEstimates.isNotEmpty
        ? technician.serviceEstimates.first.priceLabel
        : 'Hubungi';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.technicianDetail,
        arguments: technician,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: technician.photoUrl != null &&
                      technician.photoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(technician.photoUrl!,
                          fit: BoxFit.cover),
                    )
                  : const Icon(Icons.person_rounded,
                      color: Color(0xFF94A3B8), size: 32),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    technician.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    technician.specialty.isEmpty
                        ? technician.category
                        : technician.specialty,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 3),
                      Text(
                        technician.distanceLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.star_rounded,
                          size: 12, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        technician.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Price + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0061FF),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      size: 18, color: Color(0xFF475569)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────
class _TechnicianCardSkeleton extends StatelessWidget {
  const _TechnicianCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _shimmer(width: 64, height: 64, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmer(width: 120, height: 14),
                const SizedBox(height: 8),
                _shimmer(width: 80, height: 11),
                const SizedBox(height: 8),
                _shimmer(width: 100, height: 11),
              ],
            ),
          ),
          _shimmer(width: 50, height: 32, radius: 8),
        ],
      ),
    );
  }

  Widget _shimmer({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onExplore;
  const _EmptyState({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          const Text(
            'Belum ada teknisi tersedia\ndi area kamu saat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onExplore,
            child: const Text(
              'Cari di radius lebih luas →',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF0061FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error State ─────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.location_off_rounded,
              size: 40, color: Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Coba lagi',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF0061FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

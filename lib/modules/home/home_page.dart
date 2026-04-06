import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../widget/app_bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      extendBody: true,
      bottomNavigationBar: const CustomerNavBar(selectedItem: AppNavItem.home),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/ELECTROVICE_LOGO_HD.png',
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                    // Bell notification
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
              ),

              // ── Hero Map Card ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _HeroMapCard(),
              ),

              const SizedBox(height: 20),

              // ── Search Bar ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _SearchBar(),
              ),

              const SizedBox(height: 16),

              // ── Current Repair Card ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _CurrentRepairCard(),
              ),

              const SizedBox(height: 24),

              // ── Repair Categories ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _RepairCategories(),
              ),

              const SizedBox(height: 28),

              // ── Featured Specialists ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _FeaturedSpecialists(),
              ),

              // Bottom padding for nav bar
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HERO MAP CARD
// ═══════════════════════════════════════════════════════════════
class _HeroMapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Map background image
            Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.35),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, err, _st) =>
                  Container(color: const Color(0xFF334155)),
            ),

            // Wrench / pin icon in the map
            Positioned(
              top: 52,
              left: MediaQuery.of(context).size.width * 0.32,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.build_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

            // Bottom frosted card
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Text left
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Find Nearby\nTechnicians',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '12 active specialists available now',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Explore Map button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Explore Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
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

// ═══════════════════════════════════════════════════════════════
//  SEARCH BAR
// ═══════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(
            child: TextField(
              onSubmitted: (_) => Get.toNamed(AppRoutes.technicianList),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              decoration: const InputDecoration(
                hintText: 'Search for hardware repair...',
                hintStyle: TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.technicianList),
            child: Container(
              margin: const EdgeInsets.all(6),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CURRENT REPAIR CARD
// ═══════════════════════════════════════════════════════════════
class _CurrentRepairCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Color(0xFF334155),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT REPAIR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'MacBook Pro M1 •\nScreen Replacement',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0061FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'IN PROGRESS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  REPAIR CATEGORIES
// ═══════════════════════════════════════════════════════════════
class _RepairCategories extends StatelessWidget {
  static const _categories = [
    {'icon': Icons.tv_rounded, 'label': 'TV & AUDIO'},
    {'icon': Icons.laptop_rounded, 'label': 'COMPUTERS'},
    {'icon': Icons.kitchen_rounded, 'label': 'APPLIANCES'},
    {'icon': Icons.directions_car_rounded, 'label': 'VEHICLES'},
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
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Repair Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0061FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _categories.map((c) {
              return _CategoryItem(
                icon: c['icon'] as IconData,
                label: c['label'] as String,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
//  FEATURED SPECIALISTS
// ═══════════════════════════════════════════════════════════════
class _FeaturedSpecialists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Specialists',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 14),
        _SpecialistCard(
          name: 'Marcus Thorne',
          specialty: 'HEAVY APPLIANCES EXPERT',
          rating: '4.9',
          distance: '0.8 km',
          badge: const _VerifiedBadge(),
          imageUrl: 'https://i.pravatar.cc/300?u=marcus',
        ),
        const SizedBox(height: 12),
        _SpecialistCard(
          name: 'Elena Rodriguez',
          specialty: 'IT & COMPUTING',
          rating: '5.0',
          distance: '1.2 km',
          badge: const _JobsBadge(jobs: '200+ Jobs'),
          imageUrl: 'https://i.pravatar.cc/300?u=elena_rodriguez',
        ),
      ],
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String rating;
  final String distance;
  final Widget badge;
  final String imageUrl;

  const _SpecialistCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.distance,
    required this.badge,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.technicianDetail),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF94A3B8),
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A00),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              rating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D4ED8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Distance + badge
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF94A3B8),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      badge,
                    ],
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

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified_rounded, color: Color(0xFF0061FF), size: 14),
        SizedBox(width: 3),
        Text(
          'Pro Verified',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _JobsBadge extends StatelessWidget {
  final String jobs;
  const _JobsBadge({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.history_rounded, color: Color(0xFF94A3B8), size: 14),
        const SizedBox(width: 3),
        Text(
          jobs,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';

class TechnicianListPage extends StatelessWidget {
  const TechnicianListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildFilters(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                children: const [
                  SizedBox(height: 10),
                  _TechnicianCard(
                    name: 'Marcus Thorne',
                    specialty: 'Laptop Specialist',
                    experience: '8 yrs',
                    rating: '4.9',
                    distance: '1.2 km',
                    isVerified: true,
                    statusBadge: 'VERIFIED',
                    price: r'$45.00',
                  ),
                  SizedBox(height: 16),
                  _TechnicianCard(
                    name: 'Elena Rodriguez',
                    specialty: 'Precision Micro-Soldering',
                    experience: '12 yrs',
                    rating: '4.8',
                    distance: '3.5 km',
                    isVerified: false,
                    statusBadge: 'PRO',
                    price: r'$60.00',
                  ),
                  SizedBox(height: 16),
                  _TechnicianCard(
                    name: 'James Wilson',
                    specialty: 'MacBook & iPhone Specialist',
                    experience: '6 yrs',
                    rating: '4.7',
                    distance: '0.8 km',
                    isVerified: true,
                    statusBadge: 'RISING STAR',
                    price: r'$35.00',
                  ),
                  SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            splashRadius: 24,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Find Technicians',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        height: 60,
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
          children: [
            const SizedBox(width: 20),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for hardware repair...',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          _FilterChip(
            label: 'DISTANCE',
            subLabel: '<5km',
            isSelected: true,
            color: Color(0xFFDAE6FF),
            textColor: Color(0xFF0056FF),
          ),
          _FilterChip(
            label: 'RATING',
            subLabel: '★ 4.5+',
            isSelected: false,
          ),
          _FilterChip(
            label: 'PRICE',
            subLabel: r'$20 - $100',
            isSelected: false,
          ),
          _FilterChip(
            label: 'Open Now',
            icon: Icons.access_time_rounded,
            isSelected: false,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? subLabel;
  final IconData? icon;
  final bool isSelected;
  final Color? color;
  final Color? textColor;

  const _FilterChip({
    required this.label,
    this.subLabel,
    this.icon,
    this.isSelected = false,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor ?? const Color(0xFF0F172A)),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: textColor?.withValues(alpha: 0.6) ?? const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(width: 6),
            Text(
              subLabel!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: textColor ?? const Color(0xFF0F172A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TechnicianCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String experience;
  final String rating;
  final String distance;
  final bool isVerified;
  final String statusBadge;
  final String price;

  const _TechnicianCard({
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.distance,
    required this.isVerified,
    required this.statusBadge,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeTextColor;
    switch (statusBadge) {
      case 'VERIFIED':
        badgeColor = const Color(0xFFFFDAB9).withValues(alpha: 0.5);
        badgeTextColor = const Color(0xFF92400E);
        break;
      case 'PRO':
        badgeColor = const Color(0xFFDAE6FF);
        badgeTextColor = const Color(0xFF1E40AF);
        break;
      case 'RISING STAR':
        badgeColor = const Color(0xFFE2E8F0);
        badgeTextColor = const Color(0xFF475569);
        break;
      default:
        badgeColor = const Color(0xFFF1F5F9);
        badgeTextColor = const Color(0xFF64748B);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder Image
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF94A3B8),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$specialty • $experience',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusBadge,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: badgeTextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distance,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFF0061FF),
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Price & Book Now
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED PRICE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0056FF),
                        ),
                        children: [
                          TextSpan(text: price),
                          const TextSpan(
                            text: ' / service',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.technicianDetail),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

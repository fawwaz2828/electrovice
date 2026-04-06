import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/technician_model.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../../config/routes.dart';
import 'technician_controller.dart';

class TechnicianProfilePage extends GetView<TechnicianController> {
  const TechnicianProfilePage({super.key});

  static const Color _background = Color(0xFFF2F3F7);
  static const Color _ink = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      extendBody: true,
      bottomNavigationBar:
          const TechnicianNavBar(selectedItem: AppNavItem.profile),
      body: SafeArea(
        child: Obx(() {
          if (controller.profile.value == null) {
            return const _ProfileSkeleton();
          }

          final TechnicianProfileData data = controller.profile.value!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildTopBar(),
                const SizedBox(height: 16),
                _ProfileHeroCard(data: data),
                const SizedBox(height: 16),
                _StatsGrid(data: data),
                const SizedBox(height: 32),
                _ServiceHistoryHeader(label: data.completedWindowLabel),
                const SizedBox(height: 16),
                ...data.serviceHistory.map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _HistoryCard(job: job),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLogoutButton(context),
                const SizedBox(height: 120),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Top Bar — settings icon sekarang navigasi ke edit page ──
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: _ink,
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.technicianProfileEdit)?.then((_) {
              // Reload data setelah balik dari edit
              Get.find<TechnicianController>().refreshProfile();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.settings_outlined, color: _ink, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0BEB8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE11D48).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE11D48), size: 20),
            SizedBox(width: 10),
            Text(
              'LOG OUT SYSTEM',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFFE11D48),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w900, color: _ink),
        ),
        content: const Text(
          'Are you sure you want to log out of the technician system?',
          style: TextStyle(
              color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                  color: Color(0xFF94A3B8), fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ── Widget classes di bawah tidak berubah sama sekali ──────────────

class _ProfileHeroCard extends StatelessWidget {
  final TechnicianProfileData data;
  const _ProfileHeroCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded,
                      color: Color(0xFF94A3B8), size: 60),
                ),
              ),
              Positioned(
                bottom: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3254FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.verified_user_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            data.fullName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data.specialty.isEmpty ? 'Belum diisi' : data.specialty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3254FF),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final TechnicianProfileData data;
  const _StatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatBox(
                value: '${data.yearsExperience}+', label: 'YEARS EXP.')),
        const SizedBox(width: 12),
        Expanded(
            child: _StatBox(
                value: '${data.successRate}%', label: 'SUCCESS')),
        const SizedBox(width: 12),
        Expanded(
            child: _StatBox(
                value: data.rating.toStringAsFixed(1),
                label: '★',
                labelIsIcon: true)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool labelIsIcon;
  const _StatBox(
      {required this.value, required this.label, this.labelIsIcon = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          if (labelIsIcon)
            const Icon(Icons.star_rounded,
                color: Color(0xFF3254FF), size: 18)
          else
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _ServiceHistoryHeader extends StatelessWidget {
  final String label;
  const _ServiceHistoryHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.history_rounded, color: Color(0xFF0F172A), size: 20),
            SizedBox(width: 8),
            Text('Service History',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
          ],
        ),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.5)),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TechnicianJobRecord job;
  const _HistoryCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.3)),
                    const SizedBox(height: 6),
                    Text('Client: ${job.clientName}',
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${job.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(job.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF59E0B), size: 16),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job.completedDateLabel,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF2FF),
                  foregroundColor: const Color(0xFF3254FF),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(120, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('View Receipt',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatefulWidget {
  const _ProfileSkeleton();

  @override
  State<_ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<_ProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final Color shimmer =
            Colors.grey.withOpacity(_animation.value);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Top bar skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _box(shimmer, width: 80, height: 24),
                  _box(shimmer, width: 38, height: 38, radius: 12),
                ],
              ),
              const SizedBox(height: 16),
              // Hero card skeleton
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _box(shimmer, width: 120, height: 120, radius: 20),
                    const SizedBox(height: 24),
                    _box(shimmer, width: 180, height: 24),
                    const SizedBox(height: 16),
                    _box(shimmer, width: 220, height: 40, radius: 12),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Stats skeleton
              Row(
                children: [
                  Expanded(child: _statBox(shimmer)),
                  const SizedBox(width: 12),
                  Expanded(child: _statBox(shimmer)),
                  const SizedBox(width: 12),
                  Expanded(child: _statBox(shimmer)),
                ],
              ),
              const SizedBox(height: 32),
              // History skeleton
              _box(shimmer, width: double.infinity, height: 120, radius: 24),
              const SizedBox(height: 16),
              _box(shimmer, width: double.infinity, height: 120, radius: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _box(Color color,
      {double? width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _statBox(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _box(color, width: 40, height: 20),
          const SizedBox(height: 6),
          _box(color, width: 50, height: 12),
        ],
      ),
    );
  }
}
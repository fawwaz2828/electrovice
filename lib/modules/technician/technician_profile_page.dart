import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/technician_model.dart';
import '../../services/auth_service.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../../widgets/skeleton_widgets.dart';
import 'technician_controller.dart';

class TechnicianProfilePage extends GetView<TechnicianController> {
  const TechnicianProfilePage({super.key});

  static const Color _bg   = Color(0xFFF2F3F7);
  static const Color _ink  = Color(0xFF0A0A0A);
  static const Color _muted= Color(0xFF64748B);
  static const Color _red  = Color(0xFFE11D48);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBody: true,
      bottomNavigationBar: const TechnicianNavBar(
        selectedItem: AppNavItem.profile,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.profile.value == null) {
            return const _ProfileSkeleton();
          }
          final data = controller.profile.value!;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
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
                      _IconBtn(
                        icon: Icons.edit_outlined,
                        onTap: () => Get.toNamed(AppRoutes.technicianProfileEdit)
                            ?.then((_) => controller.refreshProfile()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Profile hero ──────────────────────────────────────
                _ProfileHero(data: data),
                const SizedBox(height: 16),

                // ── Stats row ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: _StatBox(
                        value: '${data.yearsExperience}+',
                        label: 'YEARS EXP.',
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatBox(
                        value: '${data.successRate}%',
                        label: 'SUCCESS',
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatBox(
                        value: data.rating.toStringAsFixed(1),
                        label: 'RATING',
                        isRating: true,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Account Settings section ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'ACCOUNT SETTINGS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _muted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.build_outlined,
                      label: 'Services List',
                      subtitle: 'Manage your service offerings',
                      onTap: () => Get.toNamed(AppRoutes.myService),
                    ),
                    const _Divider(),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      label: 'Saved Addresses',
                      subtitle: 'Workshop & service locations',
                      onTap: () => Get.toNamed(AppRoutes.technicianSavedAddress),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Logout ────────────────────────────────────────────
                _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      labelColor: _red,
                      iconColor: _red,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w900, color: _ink),
        ),
        content: const Text(
          'Are you sure you want to log out of the technician system?',
          style: TextStyle(color: _muted, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService().logout();
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ── Icon button (top bar) ────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF0A0A0A), width: 1),
        ),
        child: Icon(icon, color: const Color(0xFF0A0A0A), size: 20),
      ),
    );
  }
}

// ── Profile hero card ────────────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final TechnicianProfileData data;
  const _ProfileHero({required this.data});

  static const Color _blue = Color(0xFF0061FF);
  static const Color _ink  = Color(0xFF0A0A0A);
  static const Color _muted= Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1),
      ),
      child: Column(
        children: [
          // Avatar circle
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEEF4FF),
                  image: (data.avatarUrl != null && data.avatarUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(data.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (data.avatarUrl == null || data.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person_rounded,
                        color: Color(0xFF0061FF), size: 48)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            data.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _ink,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (data.yearsExperience > 0) ...[
            const SizedBox(height: 6),
            Text(
              '${data.yearsExperience} years of experience',
              style: const TextStyle(
                fontSize: 12,
                color: _muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 14),
          // Service Categories chips
          _ServiceCategoriesChips(),
        ],
      ),
    );
  }
}

// ── Service Categories chips (read-only) ─────────────────────────────────────
class _ServiceCategoriesChips extends StatelessWidget {
  _ServiceCategoriesChips();

  static const _labels = {
    'laptop': 'Laptop',
    'smartphone': 'Smartphone',
    'appliance': 'Home Appliance',
    'ac': 'AC & Cooling',
    'tv': 'TV & Display',
    'vehicle': 'Vehicles',
    'other': 'Other',
  };

  final _ctrl = Get.find<TechnicianController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = _ctrl.deviceCategories;
      if (cats.isEmpty) return const SizedBox.shrink();
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: cats.map((key) {
          final label = _labels[key] ?? key;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBDD0FF), width: 1),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0061FF),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

// ── Stat box ─────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool isRating;
  const _StatBox({
    required this.value,
    required this.label,
    this.isRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1),
      ),
      child: Column(
        children: [
          if (isRating)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.star_rounded,
                    color: Color(0xFFF59E0B), size: 16),
              ],
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0A0A0A),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu card wrapper ─────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1),
      ),
      child: Column(children: children),
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.labelColor,
    this.iconColor,
    required this.onTap,
  });

  static const Color _ink  = Color(0xFF0A0A0A);
  static const Color _muted= Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? Color(0xFF0061FF))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: iconColor ?? const Color(0xFF0061FF), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: labelColor ?? _ink,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: (labelColor ?? _muted).withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 72, endIndent: 18,
        color: Color(0xFFF1F5F9));
  }
}

// ── Skeleton ─────────────────────────────────────────────────────────────────
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonBox(width: 80, height: 26),
                const SkeletonBox(width: 40, height: 40, radius: 12),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF0A0A0A), width: 1),
              ),
              child: const Column(
                children: [
                  SkeletonCircle(size: 96),
                  SizedBox(height: 16),
                  SkeletonBox(width: 160, height: 22),
                  SizedBox(height: 8),
                  SkeletonBox(width: 120, height: 14, radius: 6),
                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonBox(width: 80, height: 26, radius: 20),
                      SizedBox(width: 8),
                      SkeletonBox(width: 80, height: 26, radius: 20),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatSkeleton()),
                const SizedBox(width: 12),
                Expanded(child: _StatSkeleton()),
                const SizedBox(width: 12),
                Expanded(child: _StatSkeleton()),
              ],
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: SkeletonBox(width: 120, height: 12, radius: 6),
            ),
            const SizedBox(height: 10),
            const SkeletonBox(width: double.infinity, height: 180, radius: 20),
            const SizedBox(height: 12),
            const SkeletonBox(width: double.infinity, height: 64, radius: 20),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1),
      ),
      child: const Column(
        children: [
          SkeletonBox(width: 40, height: 20),
          SizedBox(height: 4),
          SkeletonBox(width: 50, height: 10, radius: 5),
        ],
      ),
    );
  }
}

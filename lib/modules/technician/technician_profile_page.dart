import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../models/technician_model.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'technician_controller.dart';

class TechnicianProfilePage extends GetView<TechnicianController> {
  const TechnicianProfilePage({super.key});

  static const Color _background = Color(0xFFF4F4F4);
  static const Color _card = Colors.white;
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF7B8091);
  static const Color _line = Color(0xFFE7E8ED);
  static const Color _blueChip = Color(0xFFDCE8FF);
  static const Color _blueText = Color(0xFF2B4E91);
  static const Color _accent = Color(0xFF3151FF);
  static const List<AppBottomNavEntry> _navItems = [
    AppBottomNavEntry(
      item: AppNavItem.home,
      icon: Icons.home_filled,
      label: 'HOME',
    ),
    AppBottomNavEntry(
      item: AppNavItem.active,
      icon: Icons.handyman_outlined,
      label: 'ACTIVE',
    ),
    AppBottomNavEntry(
      item: AppNavItem.profile,
      icon: Icons.person_outline_rounded,
      label: 'PROFILE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      bottomNavigationBar: AppBottomNavBar(
        selectedItem: AppNavItem.profile,
        onItemSelected: _onNavSelected,
        items: _navItems,
      ),
      body: SafeArea(
        child: Obx(() {
          final TechnicianProfileData data =
              controller.profile.value ?? TechnicianProfileData.sample();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 16),
                _ProfileHero(data: data),
                const SizedBox(height: 14),
                _StatsRow(data: data),
                const SizedBox(height: 14),
                _ServiceHistoryHeader(label: data.completedWindowLabel),
                const SizedBox(height: 10),
                ...data.serviceHistory.map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _HistoryCard(job: job),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Profile',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, color: Colors.black),
          splashRadius: 20,
        ),
      ],
    );
  }

  void _onNavSelected(AppNavItem item) {
    switch (item) {
      case AppNavItem.profile:
        return;
      case AppNavItem.home:
        Get.offNamed(AppRoutes.home);
        return;
      case AppNavItem.active:
        Get.snackbar(
          'Coming soon',
          'Technician active jobs view is not ready yet.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      case AppNavItem.history:
      case AppNavItem.order:
        return;
    }
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.data});

  final TechnicianProfileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: TechnicianProfilePage._card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _TechnicianAvatar(imageUrl: data.avatarUrl),
          const SizedBox(height: 12),
          Text(
            data.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TechnicianProfilePage._ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: TechnicianProfilePage._blueChip,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data.specialty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TechnicianProfilePage._blueText,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicianAvatar extends StatelessWidget {
  const _TechnicianAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 102,
          height: 102,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFE7EEF9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null && imageUrl!.trim().isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _TechnicianAvatarFallback(),
                  )
                : const _TechnicianAvatarFallback(),
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: TechnicianProfilePage._blueText,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }
}

class _TechnicianAvatarFallback extends StatelessWidget {
  const _TechnicianAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F2D48), Color(0xFF05070B)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: Color(0xFFC8D0DD),
          size: 56,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});

  final TechnicianProfileData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '${data.yearsExperience}+',
            label: 'YEARS EXP.',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: '${data.successRate}%',
            label: 'SUCCESS',
            valueColor: const Color(0xFF7A541A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: data.rating.toStringAsFixed(1),
            icon: Icons.star,
            iconColor: TechnicianProfilePage._accent,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    this.label,
    this.icon,
    this.valueColor = TechnicianProfilePage._ink,
    this.labelColor = TechnicianProfilePage._muted,
    this.iconColor = TechnicianProfilePage._muted,
  });

  final String value;
  final String? label;
  final IconData? icon;
  final Color valueColor;
  final Color labelColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: TechnicianProfilePage._card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          if (icon != null)
            Icon(icon, color: iconColor, size: 16)
          else if (label != null)
            Text(
              label!,
              style: TextStyle(
                color: labelColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceHistoryHeader extends StatelessWidget {
  const _ServiceHistoryHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.history_rounded, color: Colors.black, size: 20),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Service History',
            style: TextStyle(
              color: TechnicianProfilePage._ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: TechnicianProfilePage._muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.job});

  final TechnicianJobRecord job;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: TechnicianProfilePage._card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
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
                    Text(
                      job.title,
                      style: const TextStyle(
                        color: TechnicianProfilePage._ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Client: ${job.clientName}',
                      style: const TextStyle(
                        color: TechnicianProfilePage._muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(job.amount),
                    style: const TextStyle(
                      color: TechnicianProfilePage._ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        job.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: TechnicianProfilePage._ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.star, color: Color(0xFFF4A340), size: 14),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: TechnicianProfilePage._line, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  job.completedDateLabel,
                  style: const TextStyle(
                    color: TechnicianProfilePage._muted,
                    fontSize: 13,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD7E6FF),
                  foregroundColor: TechnicianProfilePage._blueText,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View Receipt',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount == amount.roundToDouble()) {
      return '\$${amount.toStringAsFixed(2)}';
    }

    return '\$${amount.toStringAsFixed(2)}';
  }
}

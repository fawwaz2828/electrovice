import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../models/profile_model.dart';
import '../../services/auth_service.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  static const Color _pageBackground = Color(0xFFF8F9FD);
  static const Color _cardBackground = Colors.white;
  static const Color _line = Color(0xFFE5EAF3);
  static const Color _title = Color(0xFF111111);
  static const Color _muted = Color(0xFF6F88AE);
  static const Color _label = Color(0xFFC0C8D7);
  static const Color _fieldBackground = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      bottomNavigationBar: const CustomerNavBar(selectedItem: AppNavItem.profile),
      body: SafeArea(
        child: Obx(() {
          final ProfileData data =
              controller.profile.value ?? ProfileData.sample();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 30),
                Center(child: _AvatarCard(imageUrl: data.avatarUrl)),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    data.fullName,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                const _SectionTitle(title: 'PERSONAL IDENTITY'),
                const SizedBox(height: 16),
                _CardShell(
                  child: Column(
                    children: [
                      _InfoField(
                        label: 'FULL NAME',
                        value: data.fullName,
                      ),
                      const SizedBox(height: 22),
                      _InfoField(
                        label: 'EMAIL ADDRESS',
                        value: data.emailAddress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const _SectionTitle(title: 'CONNECTIVITY'),
                const SizedBox(height: 16),
                _CardShell(
                  child: _PhoneField(
                    label: 'MOBILE NUMBER',
                    value: data.mobileNumber,
                    isVerified: data.isMobileVerified,
                  ),
                ),
                const SizedBox(height: 30),
                const _SectionTitle(title: 'PRIMARY NODES'),
                const SizedBox(height: 16),
                ...data.primaryNodes.map(
                  (node) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NodeTile(node: node),
                  ),
                ),
                const SizedBox(height: 26),
                const _SectionTitle(title: 'SECURITY PROTOCOLS'),
                const SizedBox(height: 16),
                _CardShell(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (
                        int index = 0;
                        index < data.securityOptions.length;
                        index++
                      ) ...[
                        _SecurityTile(option: data.securityOptions[index]),
                        if (index != data.securityOptions.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: _line,
                            indent: 18,
                            endIndent: 18,
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildLogoutButton(context),
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
              color: _title,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            Get.toNamed(AppRoutes.profileEdit);
          },
          icon: const Icon(
            Icons.settings_outlined,
            color: Colors.black,
            size: 26,
          ),
          splashRadius: 22,
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
            Icon(
              Icons.logout_rounded,
              color: Color(0xFFE11D48),
              size: 20,
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w900, color: _title),
        ),
        content: const Text(
          'Are you sure you want to log out of the system?',
          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // tutup dialog dulu
              await AuthService().logout();
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 138,
          height: 138,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const _AvatarPlaceholder(),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 17,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1E8DC),
            Color(0xFFE9EEF9),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0xFF0D1421),
                  ],
                ),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.person_rounded,
              size: 78,
              color: Color(0xFF505A69),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ProfilePage._muted,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Divider(
            color: ProfilePage._line,
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: ProfilePage._cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D14213D),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ProfilePage._label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: ProfilePage._fieldBackground,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2A2A2A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.label,
    required this.value,
    required this.isVerified,
  });

  final String label;
  final String value;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ProfilePage._label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: ProfilePage._fieldBackground,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF2A2A2A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEFF4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NodeTile extends StatelessWidget {
  const _NodeTile({required this.node});

  final ProfileNode node;

  @override
  Widget build(BuildContext context) {
    final _NodeVisual visual = _NodeVisual.fromType(node.type);

    return _CardShell(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: visual.backgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(visual.icon, color: visual.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.title,
                  style: const TextStyle(
                    color: Color(0xFF23262F),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  node.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF515B6F),
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF767E91)),
          const SizedBox(width: 16),
          const Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: Color(0xFF767E91),
          ),
        ],
      ),
    );
  }
}

class _NodeVisual {
  const _NodeVisual({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  factory _NodeVisual.fromType(String type) {
    switch (type) {
      case 'home':
        return const _NodeVisual(
          icon: Icons.home_outlined,
          backgroundColor: Colors.black,
          iconColor: Colors.white,
        );
      case 'hq':
        return const _NodeVisual(
          icon: Icons.handyman_outlined,
          backgroundColor: Color(0xFFDCE8FB),
          iconColor: Colors.black,
        );
      default:
        return const _NodeVisual(
          icon: Icons.place_outlined,
          backgroundColor: Color(0xFFECEFF6),
          iconColor: Colors.black,
        );
    }
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({required this.option});

  final SecurityOption option;

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (option.key) {
      'change_access_key' => Icons.lock_reset_rounded,
      'privacy_management' => Icons.shield_outlined,
      _ => Icons.chevron_right_rounded,
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Icon(icon, color: Colors.black, size: 23),
      title: Text(
        option.title,
        style: const TextStyle(
          color: Color(0xFF1C1C1C),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF6F7788),
      ),
      onTap: () {},
    );
  }
}

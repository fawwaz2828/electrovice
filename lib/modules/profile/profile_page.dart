import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color _navy = Color(0xFF183B72);
  static const Color _blue = Color(0xFF4461F2);
  static const Color _bg = Color(0xFFF7F8FC);
  static const Color _line = Color(0xFFE4E9F2);
  static const Color _muted = Color(0xFF7D8FB3);
  static const Color _softText = Color(0xFFB6C0D2);
  static const Color _surface = Colors.white;
  static const Color _danger = Color(0xFFD34234);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 36),
                    _SectionTitle(title: 'PERSONAL IDENTITY'),
                    const SizedBox(height: 14),
                    _CardShell(
                      child: Column(
                        children: const [
                          _FieldBlock(
                            label: 'FULL NAME',
                            value: 'Alex Johnson',
                          ),
                          SizedBox(height: 18),
                          _FieldBlock(
                            label: 'EMAIL ADDRESS',
                            value: 'alex.johnson@gmail.com',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _SectionTitle(title: 'CONNECTIVITY'),
                    const SizedBox(height: 14),
                    _CardShell(
                      child: Column(
                        children: const [
                          _PhoneBlock(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _SectionTitle(title: 'PRIMARY NODES'),
                    const SizedBox(height: 14),
                    const _NodeCard(
                      icon: Icons.home_rounded,
                      iconBg: _blue,
                      title: 'Home Base',
                      subtitle: '241 Oak Ridge, Ste 402 North\nHills, CA 91343',
                    ),
                    const SizedBox(height: 12),
                    const _NodeCard(
                      icon: Icons.handyman_outlined,
                      iconBg: Color(0xFFDDE7F8),
                      iconColor: _navy,
                      title: 'Headquarters',
                      subtitle: 'Tech Plaza, Building B, Floor 12',
                    ),
                    const SizedBox(height: 30),
                    _SectionTitle(title: 'SECURITY PROTOCOLS'),
                    const SizedBox(height: 14),
                    _CardShell(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: const [
                          _SecurityTile(
                            icon: Icons.lock_reset_rounded,
                            title: 'Change Access Key',
                          ),
                          Divider(height: 1, thickness: 1, color: _line),
                          _SecurityTile(
                            icon: Icons.shield_outlined,
                            title: 'Privacy Management',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildLogoutButton(context),
                    const SizedBox(height: 34),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F2F7))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _navy),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  color: _navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: _navy),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 124,
              height: 154,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x150A1E42),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF7F1E8), Color(0xFFD5DAE8)],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0, -0.5),
                          radius: 1.05,
                          colors: [Color(0xFFFBF5EC), Color(0xFFD8DDEA)],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 62,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0xDD152847)],
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 82,
                        color: Color(0xFF394B66),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _navy,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit_outlined, size: 17, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Alex Johnson',
          style: TextStyle(
            color: _navy,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: _danger,
          side: const BorderSide(color: Color(0xFFF1BDB7)),
          backgroundColor: const Color(0xFFFFFCFC),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'LOG OUT SYSTEM',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140D2348),
            blurRadius: 28,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(icon: Icons.home_rounded, label: 'HOME'),
          _BottomNavItem(icon: Icons.history_rounded, label: 'HISTORY'),
          _BottomNavItem(icon: Icons.receipt_long_rounded, label: 'ORDER'),
          _BottomNavItem(
            icon: Icons.person_outline_rounded,
            label: 'PROFILE',
            selected: true,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out of the system?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: _danger),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
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
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(width: 12),
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
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: ProfilePage._surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1A2E52),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
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
            color: ProfilePage._softText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2A2A2A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneBlock extends StatelessWidget {
  const _PhoneBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MOBILE NUMBER',
          style: TextStyle(
            color: ProfilePage._softText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '+1 (555) 012-3456',
                  style: TextStyle(
                    color: Color(0xFF2A2A2A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: ProfilePage._navy),
                    SizedBox(width: 5),
                    Text(
                      'VERIFIED',
                      style: TextStyle(
                        color: ProfilePage._navy,
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

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF232F46),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF4F5D75),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF66748D)),
          const SizedBox(width: 14),
          const Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: Color(0xFF66748D),
          ),
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FD),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, size: 18, color: ProfilePage._navy),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1F2B3E),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF6D7891),
      ),
      onTap: () {},
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? ProfilePage._blue : const Color(0xFFA3AEC4);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: selected ? 14 : 6,
        vertical: selected ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF1F5FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

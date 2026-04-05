import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/routes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'HOME',
              index: 0,
              isActive: currentIndex == 0,
              onTap: () {
                if (currentIndex != 0) Get.offAllNamed(AppRoutes.home);
              },
            ),
            _buildNavItem(
              icon: Icons.history_rounded,
              label: 'HISTORY',
              index: 1,
              isActive: currentIndex == 1,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.receipt_long_rounded,
              label: 'ORDER',
              index: 2,
              isActive: currentIndex == 2,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'PROFILE',
              index: 3,
              isActive: currentIndex == 3,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0F2B5B).withValues(alpha: 0.75)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isActive ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                    isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF9CA3AF),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

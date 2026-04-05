import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/routes.dart';

class TechnicianNavBar extends StatelessWidget {
  const TechnicianNavBar({super.key, required this.selectedItem});

  final AppNavItem selectedItem;

  void _onNavSelected(AppNavItem item) {
    if (item == selectedItem) return;

    switch (item) {
      case AppNavItem.home:
        Get.offNamed(AppRoutes.technicianHome);
        break;
      case AppNavItem.active:
        Get.offNamed(AppRoutes.activeJob);
        break;
      case AppNavItem.profile:
        Get.offNamed(AppRoutes.technicianProfile);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomNavBar(
      selectedItem: selectedItem,
      onItemSelected: _onNavSelected,
      items: AppBottomNavBar.technicianItems,
    );
  }
}

enum AppNavItem {
  home,
  active,
  history,
  order,
  profile,
}

class AppBottomNavEntry {
  const AppBottomNavEntry({
    required this.item,
    required this.icon,
    required this.label,
  });

  final AppNavItem item;
  final IconData icon;
  final String label;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    this.items = _defaultItems,
  });

  final AppNavItem selectedItem;
  final ValueChanged<AppNavItem> onItemSelected;
  final List<AppBottomNavEntry> items;

  static const Color _background = Colors.black;
  static const Color _inactive = Color(0xFF9CA3AF);
  static const Color _active = Color(0xFF3B82F6);
  static const List<AppBottomNavEntry> _defaultItems = [
    AppBottomNavEntry(
      item: AppNavItem.home,
      icon: Icons.home_rounded,
      label: 'HOME',
    ),
    AppBottomNavEntry(
      item: AppNavItem.history,
      icon: Icons.history_rounded,
      label: 'HISTORY',
    ),
    AppBottomNavEntry(
      item: AppNavItem.order,
      icon: Icons.receipt_long_rounded,
      label: 'ORDER',
    ),
    AppBottomNavEntry(
      item: AppNavItem.profile,
      icon: Icons.person_rounded,
      label: 'PROFILE',
    ),
  ];

  static const List<AppBottomNavEntry> technicianItems = [
    AppBottomNavEntry(
      item: AppNavItem.home,
      icon: Icons.home_filled,
      label: 'HOME',
    ),
    AppBottomNavEntry(
      item: AppNavItem.active,
      icon: Icons.build_rounded,
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
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: _background,
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
          children: items
              .map(
                (entry) => _NavBarItem(
                  entry: entry,
                  selected: entry.item == selectedItem,
                  onTap: () => onItemSelected(entry.item),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? AppBottomNavBar._active : AppBottomNavBar._inactive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0F2B5B).withValues(alpha: 0.75)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(entry.icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(
              entry.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

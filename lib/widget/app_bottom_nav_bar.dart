import 'package:flutter/material.dart';

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

  static const Color _background = Color(0xFF030303);
  static const Color _inactive = Color(0xFF8E97B1);
  static const Color _active = Color(0xFF3254FF);
  static const List<AppBottomNavEntry> _defaultItems = [
    AppBottomNavEntry(
      item: AppNavItem.home,
      icon: Icons.home_filled,
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
      icon: Icons.person_outline_rounded,
      label: 'PROFILE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(34),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, 10),
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
          color: selected ? const Color(0xFF0E1A52) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
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

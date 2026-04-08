import 'dart:ui';
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

class CustomerNavBar extends StatelessWidget {
  const CustomerNavBar({super.key, required this.selectedItem});

  final AppNavItem selectedItem;

  void _onNavSelected(AppNavItem item) {
    if (item == selectedItem) return;

    switch (item) {
      case AppNavItem.home:
        Get.offNamed(AppRoutes.home);
        break;
      case AppNavItem.history:
        Get.offNamed(AppRoutes.orderHistory);
        break;
      case AppNavItem.order:
        Get.offNamed(AppRoutes.orderTracking);
        break;
      case AppNavItem.profile:
        Get.offNamed(AppRoutes.profilePage);
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
    required this.activeIcon,
    required this.label,
  });

  final AppNavItem item;
  final IconData icon;
  final IconData activeIcon;
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
  static const Color _active = Color(0xFF0061FF);

  static const List<AppBottomNavEntry> _defaultItems = [
    AppBottomNavEntry(
      item: AppNavItem.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'HOME',
    ),
    AppBottomNavEntry(
      item: AppNavItem.history,
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'HISTORY',
    ),
    AppBottomNavEntry(
      item: AppNavItem.order,
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'ORDER',
    ),
    AppBottomNavEntry(
      item: AppNavItem.profile,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'PROFILE',
    ),
  ];

  static const List<AppBottomNavEntry> technicianItems = [
    AppBottomNavEntry(
      item: AppNavItem.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'HOME',
    ),
    AppBottomNavEntry(
      item: AppNavItem.active,
      icon: Icons.build_outlined,
      activeIcon: Icons.build_rounded,
      label: 'ACTIVE',
    ),
    AppBottomNavEntry(
      item: AppNavItem.profile,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'PROFILE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
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
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  const _NavBarItem({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 4,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.selected) {
      _controller.forward(from: 0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.selected;
    final Color color =
        selected ? AppBottomNavBar._active : AppBottomNavBar._inactive;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 18 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppBottomNavBar._active.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            border: selected
                ? Border.all(
                    color: AppBottomNavBar._active.withValues(alpha: 0.25),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutBack,
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  selected ? widget.entry.activeIcon : widget.entry.icon,
                  color: color,
                  size: 22,
                  key: ValueKey(selected),
                ),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.6,
                ),
                child: Text(widget.entry.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

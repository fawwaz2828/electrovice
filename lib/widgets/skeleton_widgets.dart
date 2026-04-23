import 'package:flutter/material.dart';

// ── Shimmer scope ─────────────────────────────────────────────────────────────

class _ShimmerInherited extends InheritedWidget {
  final Animation<double> animation;
  const _ShimmerInherited({required this.animation, required super.child});

  static Animation<double>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerInherited>()?.animation;

  @override
  bool updateShouldNotify(_ShimmerInherited old) => true;
}

/// Wrap a skeleton layout with this to get the shimmer pulse animation.
class SkeletonShimmer extends StatefulWidget {
  final Widget child;
  const SkeletonShimmer({super.key, required this.child});

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerInherited(animation: _anim, child: widget.child);
  }
}

// ── Primitives ────────────────────────────────────────────────────────────────

Color _skeletonColor(BuildContext context) {
  final anim = _ShimmerInherited.of(context);
  if (anim == null) return const Color(0xFFE2E8F0);
  return Color.lerp(
    const Color(0xFFE2E8F0),
    Color(0xFFF8FAFC),
    anim.value,
  )!;
}

/// A shimmer-colored rectangle. Must be inside a [SkeletonShimmer].
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final anim = _ShimmerInherited.of(context);
    if (anim == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }
    return AnimatedBuilder(
      animation: anim,
      builder: (ctx, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _skeletonColor(ctx),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// A shimmer-colored circle. Must be inside a [SkeletonShimmer].
class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(width: size, height: size, radius: size / 2);
  }
}

// ── Compound components ───────────────────────────────────────────────────────

/// A single list row with a leading circle avatar and two text lines.
class SkeletonListItem extends StatelessWidget {
  final double avatarSize;
  final double titleWidth;
  final double subtitleWidth;

  const SkeletonListItem({
    super.key,
    this.avatarSize = 48,
    this.titleWidth = 140,
    this.subtitleWidth = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SkeletonCircle(size: avatarSize),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: titleWidth, height: 14),
                const SizedBox(height: 6),
                SkeletonBox(width: subtitleWidth, height: 12, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A card-shaped skeleton placeholder with a padded box inside.
class SkeletonCard extends StatelessWidget {
  final double height;
  final EdgeInsets padding;
  final Widget? child;

  const SkeletonCard({
    super.key,
    this.height = 80,
    this.padding = const EdgeInsets.all(16),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: child != null ? null : height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0A0A0A), width: 1),
      ),
      child: child ?? const SkeletonBox(height: 20),
    );
  }
}

/// Profile hero: large circle + name + subtitle lines.
class SkeletonProfileHeader extends StatelessWidget {
  final double avatarSize;
  const SkeletonProfileHeader({super.key, this.avatarSize = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkeletonCircle(size: avatarSize),
        const SizedBox(height: 12),
        SkeletonBox(width: 160, height: 18),
        const SizedBox(height: 8),
        SkeletonBox(width: 120, height: 13, radius: 6),
      ],
    );
  }
}

/// A technician card skeleton matching the featured-specialists card layout.
class SkeletonTechnicianCard extends StatelessWidget {
  const SkeletonTechnicianCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonCircle(size: 52),
          SizedBox(height: 10),
          SkeletonBox(width: 110, height: 14),
          SizedBox(height: 6),
          SkeletonBox(width: 80, height: 11, radius: 6),
          SizedBox(height: 10),
          SkeletonBox(width: 60, height: 22, radius: 12),
        ],
      ),
    );
  }
}

/// A label + field row skeleton (for form/info pages).
class SkeletonLabelField extends StatelessWidget {
  final double labelWidth;
  final double fieldHeight;

  const SkeletonLabelField({
    super.key,
    this.labelWidth = 80,
    this.fieldHeight = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: labelWidth, height: 12, radius: 6),
        const SizedBox(height: 8),
        SkeletonBox(height: fieldHeight),
      ],
    );
  }
}

/// A horizontal row of stat chips (used in technician profiles).
class SkeletonStatRow extends StatelessWidget {
  const SkeletonStatRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SkeletonBox(width: 70, height: 36, radius: 12),
        SizedBox(width: 8),
        SkeletonBox(width: 70, height: 36, radius: 12),
        SizedBox(width: 8),
        SkeletonBox(width: 70, height: 36, radius: 12),
      ],
    );
  }
}

/// Simple full-page scaffold skeleton with an optional AppBar.
///
/// [body] should be wrapped in a [SkeletonShimmer] already.
class SkeletonScaffold extends StatelessWidget {
  final bool showAppBar;
  final Widget body;

  const SkeletonScaffold({
    super.key,
    this.showAppBar = true,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: Color(0xFF0A0A0A)),
            )
          : null,
      body: body,
    );
  }
}

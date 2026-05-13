import 'package:flutter/material.dart';

/// Instagram-style verified avatar: wraps a circular avatar with a blue
/// checkmark overlay at the bottom-right when [isCertified] is true.
///
/// Usage:
/// ```dart
/// VerifiedAvatar(
///   size: 96,
///   imageUrl: technician.photoUrl,
///   isCertified: technician.isCertified,
/// )
/// ```
class VerifiedAvatar extends StatelessWidget {
  /// Avatar diameter in pixels.
  final double size;

  /// Network image URL. If null/empty, falls back to [placeholder].
  final String? imageUrl;

  /// Whether to show the blue verified checkmark.
  final bool isCertified;

  /// Background color when no image. Defaults to a soft blue tint.
  final Color? backgroundColor;

  /// Optional placeholder icon (defaults to a person icon).
  final IconData placeholder;

  const VerifiedAvatar({
    super.key,
    required this.size,
    required this.isCertified,
    this.imageUrl,
    this.backgroundColor,
    this.placeholder = Icons.person_rounded,
  });

  @override
  Widget build(BuildContext context) {
    // Badge size scales relative to avatar size (≈ 28% of diameter,
    // matching Instagram's proportions).
    final double badgeSize = (size * 0.28).clamp(14.0, 36.0);
    final double iconSize = badgeSize * 0.72;
    final double borderWidth = (size * 0.025).clamp(1.5, 4.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? const Color(0xFFEEF4FF),
              image: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? Icon(
                    placeholder,
                    color: const Color(0xFF0061FF),
                    size: size * 0.5,
                  )
                : null,
          ),
          if (isCertified)
            Positioned(
              bottom: 0,
              right: 0,
              child: _CheckmarkBadge(
                size: badgeSize,
                iconSize: iconSize,
                borderWidth: borderWidth,
              ),
            ),
        ],
      ),
    );
  }
}

class _CheckmarkBadge extends StatelessWidget {
  final double size;
  final double iconSize;
  final double borderWidth;

  const _CheckmarkBadge({
    required this.size,
    required this.iconSize,
    required this.borderWidth,
  });

  static const Color _verifiedBlue = Color(0xFF1D9BF0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _verifiedBlue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: _verifiedBlue.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: iconSize,
        weight: 900,
      ),
    );
  }
}

/// Inline "Certified" checkmark for use next to a name (no avatar).
/// Smaller, sits inline with text — like the checkmark beside Instagram
/// usernames in feeds.
class VerifiedCheckmark extends StatelessWidget {
  final double size;
  const VerifiedCheckmark({super.key, this.size = 14});

  static const Color _verifiedBlue = Color(0xFF1D9BF0);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified_rounded,
      color: _verifiedBlue,
      size: size,
    );
  }
}

import 'package:flutter/material.dart';

/// Demo-only allowlist of technician UIDs that render the "Certified" badge.
///
/// These are mock IDs for the demo build — the badge will appear next to a
/// technician's name only if their `technicians_online.uid` field matches one
/// of these strings. Replace or extend with real Firebase Auth UIDs to flag
/// production accounts as certified.
const Set<String> kCertifiedDemoUids = {
  'tech_001',
  'tech_002',
};

bool isCertifiedDemo(String? uid) =>
    uid != null && kCertifiedDemoUids.contains(uid);

/// Compact "Certified" badge designed to sit inline next to a technician name.
///
/// Two sizes:
///  - [CertifiedBadge.small] — for list items / inline with body text
///  - [CertifiedBadge.large] — for detail page headers
class CertifiedBadge extends StatelessWidget {
  final bool large;

  const CertifiedBadge({super.key}) : large = false;
  const CertifiedBadge.large({super.key}) : large = true;

  static const Color _accent = Color(0xFF3254FF);
  static const Color _bg = Color(0xFFEEF2FF);

  @override
  Widget build(BuildContext context) {
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
    final iconSize = large ? 13.0 : 11.0;
    final fontSize = large ? 11.0 : 9.5;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _accent.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded,
              size: iconSize, color: _accent),
          SizedBox(width: large ? 4 : 3),
          Text(
            'Certified',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: _accent,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

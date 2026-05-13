import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/routes.dart';
import '../services/auth_service.dart';
import '../services/certification_migration_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primary = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFF00A8E8);
  static const Color _colorPending = Color(0xFFF59E0B);
  static const Color _colorVerified = Color(0xFF10B981);
  static const Color _colorDeclined = Color(0xFFEF4444);
  static const Color _bg = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Stream semua teknisi yang sudah submit onboarding
  Stream<List<Map<String, dynamic>>> _streamTechnicians() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'technician')
        .snapshots()
        .map((snap) {
      return snap.docs
          .where((doc) => doc.data()['technicianProfile'] != null)
          .map((doc) {
        final data = doc.data();
        final profile = data['technicianProfile'] as Map<String, dynamic>;
        final cats = (profile['deviceCategories'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final name = data['name'] as String? ?? '';
        final initials = name.trim().split(' ').take(2).map((w) {
          return w.isNotEmpty ? w[0].toUpperCase() : '';
        }).join();

        // Format submitted date
        final updatedAt = data['updatedAt'] as Timestamp?;
        final submittedStr = updatedAt != null
            ? _formatDate(updatedAt.toDate())
            : '—';

        return {
          'uid': doc.id,
          'name': name,
          'initials': initials,
          'city': profile['city'] as String? ?? '—',
          'workshop': profile['workshopName'] as String? ?? 'No workshop',
          'categories': cats,
          'submitted': submittedStr,
          'status': _mapStatus(profile['verificationStatus'] as String? ?? 'pending'),
        };
      }).toList();
    });
  }

  String _mapStatus(String raw) {
    switch (raw) {
      case 'verified':
        return 'VERIFIED';
      case 'declined':
        return 'DECLINED';
      default:
        return 'PENDING';
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _streamTechnicians(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? [];
        final pending = all.where((t) => t['status'] == 'PENDING').toList();
        final verified = all.where((t) => t['status'] == 'VERIFIED').toList();
        final declined = all.where((t) => t['status'] == 'DECLINED').toList();

        return Scaffold(
          backgroundColor: _bg,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildStatsSection(pending.length, verified.length, declined.length),
              _buildTabBar(pending.length, verified.length, declined.length),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(pending, 'PENDING'),
                          _buildList(verified, 'VERIFIED'),
                          _buildList(declined, 'DECLINED'),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primary,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '● ELEc',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                TextSpan(
                  text: 'TROVICE',
                  style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'ADMIN',
            style: TextStyle(
                color: Colors.white54, fontSize: 11, letterSpacing: 1.2),
          ),
        ],
      ),
      actions: [
        _CertApprovalAction(),
        IconButton(
          tooltip: 'Migrate certifications',
          icon: const Icon(Icons.cleaning_services_rounded,
              color: Colors.white70, size: 20),
          onPressed: _confirmRunMigration,
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 22),
          onPressed: () async {
            await AuthService().logout();
            Get.offAllNamed(AppRoutes.register);
          },
        ),
      ],
    );
  }

  // ── Migration: reset legacy cert data + seed 2 demo techs ─────────
  Future<void> _confirmRunMigration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Run certification migration?'),
        content: const Text(
          'This will:\n'
          '• Set isCertified = false on ALL technicians\n'
          '• Clear accreditations & certificate URLs\n'
          '• Delete all certification_registrations docs\n'
          '• Seed demo accounts tech_001 & tech_002 as certified\n\n'
          'Safe to re-run.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Run')),
        ],
      ),
    );
    if (confirmed != true) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await CertificationMigrationService().runFullMigration();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close progress
      Get.snackbar('Migration complete', result.toString(),
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Get.snackbar('Migration failed', '$e',
          snackPosition: SnackPosition.TOP);
    }
  }

  Widget _buildStatsSection(int p, int v, int d) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildStatCard('PENDING', p, _colorPending),
          const SizedBox(width: 10),
          _buildStatCard('VERIFIED', v, _colorVerified),
          const SizedBox(width: 10),
          _buildStatCard('DECLINED', d, _colorDeclined),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text('$count',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(int p, int v, int d) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: _primary,
        unselectedLabelColor: Colors.black45,
        indicatorColor: _accent,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        tabs: [
          Tab(text: 'PENDING  $p'),
          Tab(text: 'VERIFIED  $v'),
          Tab(text: 'DECLINED  $d'),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, String type) {
    if (items.isEmpty) return _buildEmptyState(type);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildTechnicianCard(items[index]),
    );
  }

  Widget _buildEmptyState(String type) {
    final emoji = type == 'DECLINED'
        ? '📋'
        : type == 'VERIFIED'
            ? '✅'
            : '🎉';
    final message = type == 'DECLINED'
        ? 'No declined technicians'
        : type == 'VERIFIED'
            ? 'No verified technicians yet'
            : 'No pending verifications';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(Map<String, dynamic> tech) {
    final status = tech['status'] as String;
    final Color statusColor = status == 'VERIFIED'
        ? _colorVerified
        : status == 'DECLINED'
            ? _colorDeclined
            : _colorPending;
    final List<String> categories = List<String>.from(tech['categories']);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.adminVerification,
          arguments: {'uid': tech['uid']}),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE5E7EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  tech['initials'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tech['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${tech['city']}  ·  ${tech['workshop']}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: categories.map(_buildChip).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text('Submitted: ${tech['submitted']}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black38)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () => _confirmDeleteTechnician(
                      tech['uid'] as String, tech['name'] as String),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: _colorDeclined, size: 20),
                  tooltip: 'Delete technician',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete technician from BOTH users & technicians_online ────────
  Future<void> _confirmDeleteTechnician(String uid, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete technician?'),
        content: Text(
          'This will permanently delete $name from both the users and technicians_online collections. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorDeclined,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      // Delete from both collections in parallel
      await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(uid).delete(),
        FirebaseFirestore.instance
            .collection('technicians_online')
            .doc(uid)
            .delete(),
      ]);
      Get.snackbar('Deleted', '$name has been removed',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Failed to delete', '$e',
          snackPosition: SnackPosition.TOP);
    }
  }

  Widget _buildChip(String label) {
    final Map<String, Color> colorMap = {
      'Laptop': const Color(0xFF3B82F6),
      'Smartphone': Color(0xFF8B5CF6),
      'AC & Cooling': const Color(0xFF06B6D4),
      'TV & Display': Color(0xFFF59E0B),
      'Home Appliance': const Color(0xFF10B981),
      'Vehicles': Color(0xFFEF4444),
      'Printer': const Color(0xFF6B7280),
    };
    final color = colorMap[label] ?? const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Pending certification approval action (with badge count) ────────────
class _CertApprovalAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('technicians_online')
          .where('certificationStatus', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Approve certifications',
              icon: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white70, size: 20),
              onPressed: () =>
                  Get.toNamed(AppRoutes.adminCertificationApproval),
            ),
            if (count > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

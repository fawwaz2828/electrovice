import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/routes.dart';
import 'admin_controller.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AdminController _controller;

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
    _controller = Get.put(AdminController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(_controller.error.value,
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _controller.fetchTechnicians,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            _buildStatsSection(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_controller.pendingList, 'PENDING'),
                  _buildList(_controller.verifiedList, 'VERIFIED'),
                  _buildList(_controller.declinedList, 'DECLINED'),
                ],
              ),
            ),
          ],
        );
      }),
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
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white70),
          onPressed: _controller.fetchTechnicians,
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
          child: const Center(
            child: Text('SA',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildStatCard('PENDING', _controller.pendingList.length, _colorPending),
          const SizedBox(width: 10),
          _buildStatCard('VERIFIED', _controller.verifiedList.length, _colorVerified),
          const SizedBox(width: 10),
          _buildStatCard('DECLINED', _controller.declinedList.length, _colorDeclined),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
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

  Widget _buildTabBar() {
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
          Tab(text: 'PENDING  ${_controller.pendingList.length}'),
          Tab(text: 'VERIFIED  ${_controller.verifiedList.length}'),
          Tab(text: 'DECLINED  ${_controller.declinedList.length}'),
        ],
      ),
    );
  }

  Widget _buildList(List<TechnicianVerificationModel> items, String type) {
    if (items.isEmpty) return _buildEmptyState(type);
    return RefreshIndicator(
      onRefresh: _controller.fetchTechnicians,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _buildCard(items[index]),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    final String emoji;
    final String message;
    if (type == 'DECLINED') {
      emoji = '📋';
      message = 'Tidak ada yang di-decline';
    } else if (type == 'VERIFIED') {
      emoji = '✅';
      message = 'Belum ada teknisi terverifikasi';
    } else {
      emoji = '🎉';
      message = 'Tidak ada pending verifikasi';
    }
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

  Widget _buildCard(TechnicianVerificationModel tech) {
    final Color statusColor;
    if (tech.verificationStatus == 'verified') {
      statusColor = _colorVerified;
    } else if (tech.verificationStatus == 'declined') {
      statusColor = _colorDeclined;
    } else {
      statusColor = _colorPending;
    }

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.adminVerification, arguments: tech),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(tech),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tech.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${tech.city}  ·  ${tech.workshopName}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children:
                        tech.deviceCategories.map(_buildChip).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text('Submitted: ${tech.submittedLabel}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black38)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tech.verificationStatus.toUpperCase(),
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(TechnicianVerificationModel tech) {
    if (tech.photoUrl != null && tech.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          tech.photoUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialsAvatar(tech.initials),
        ),
      );
    }
    return _buildInitialsAvatar(tech.initials);
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ),
    );
  }

  Widget _buildChip(String label) {
    final Map<String, Color> colorMap = {
      'Laptop': const Color(0xFF3B82F6),
      'Smartphone': const Color(0xFF8B5CF6),
      'AC & Cooling': const Color(0xFF06B6D4),
      'TV & Display': const Color(0xFFF59E0B),
      'Home Appliance': const Color(0xFF10B981),
      'Vehicles': const Color(0xFFEF4444),
      'Printer': const Color(0xFF6B7280),
    };
    final color = colorMap[label] ?? const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

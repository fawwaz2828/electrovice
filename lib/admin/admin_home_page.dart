import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/routes.dart';

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

  // ─── HARDCODED DATA (ganti dengan Firebase nanti) ────────────────────────────
  final List<Map<String, dynamic>> _technicians = [
    {
      'id': '1',
      'name': 'Ahmad Rizki Pratama',
      'initials': 'AR',
      'city': 'Yogyakarta',
      'workshop': 'Tempat Servis Apalah',
      'categories': ['Laptop', 'Smartphone'],
      'submitted': '11 Apr 2026, 14:30',
      'status': 'PENDING',
    },
    {
      'id': '2',
      'name': 'Sari Putri Handayani',
      'initials': 'SP',
      'city': 'Jakarta Selatan',
      'workshop': 'Sari AC Expert',
      'categories': ['AC & Cooling'],
      'submitted': '10 Apr 2026, 09:15',
      'status': 'PENDING',
    },
    {
      'id': '3',
      'name': 'Budi Wicaksono',
      'initials': 'BW',
      'city': 'Bandung',
      'workshop': 'Budi Elektronik',
      'categories': ['TV & Display', 'Home Appliance'],
      'submitted': '11 Apr 2026, 08:42',
      'status': 'PENDING',
    },
    {
      'id': '4',
      'name': 'Dedi Kurniawan',
      'initials': 'DK',
      'city': 'Surabaya',
      'workshop': 'Dedi Motor Service',
      'categories': ['Vehicles'],
      'submitted': '9 Apr 2026, 16:20',
      'status': 'PENDING',
    },
    {
      'id': '5',
      'name': 'Lisa Handayani',
      'initials': 'LH',
      'city': 'Semarang',
      'workshop': 'Tanpa workshop',
      'categories': ['Laptop', 'Smartphone'],
      'submitted': '11 Apr 2026, 11:05',
      'status': 'PENDING',
    },
    {
      'id': '6',
      'name': 'Rizky Firmansyah',
      'initials': 'RF',
      'city': 'Medan',
      'workshop': 'RF Tech',
      'categories': ['Smartphone'],
      'submitted': '5 Apr 2026, 10:00',
      'status': 'VERIFIED',
    },
    {
      'id': '7',
      'name': 'Dewi Lestari',
      'initials': 'DL',
      'city': 'Makassar',
      'workshop': 'Dewi Service Center',
      'categories': ['Laptop', 'Printer'],
      'submitted': '3 Apr 2026, 14:00',
      'status': 'VERIFIED',
    },
    {
      'id': '8',
      'name': 'Hendra Gunawan',
      'initials': 'HG',
      'city': 'Palembang',
      'workshop': 'Hendra Elektronik',
      'categories': ['TV & Display'],
      'submitted': '1 Apr 2026, 09:30',
      'status': 'DECLINED',
    },
  ];
  // ─────────────────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get pendingList =>
      _technicians.where((t) => t['status'] == 'PENDING').toList();
  List<Map<String, dynamic>> get verifiedList =>
      _technicians.where((t) => t['status'] == 'VERIFIED').toList();
  List<Map<String, dynamic>> get declinedList =>
      _technicians.where((t) => t['status'] == 'DECLINED').toList();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsSection(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(pendingList, 'PENDING'),
                _buildList(verifiedList, 'VERIFIED'),
                _buildList(declinedList, 'DECLINED'),
              ],
            ),
          ),
        ],
      ),
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
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: 'TROVICE',
                  style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'ADMIN',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: _accent,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'SA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
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
          _buildStatCard('PENDING', pendingList.length, _colorPending),
          const SizedBox(width: 10),
          _buildStatCard('VERIFIED', verifiedList.length, _colorVerified),
          const SizedBox(width: 10),
          _buildStatCard('DECLINED', declinedList.length, _colorDeclined),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        tabs: [
          Tab(text: 'PENDING  ${pendingList.length}'),
          Tab(text: 'VERIFIED  ${verifiedList.length}'),
          Tab(text: 'DECLINED  ${declinedList.length}'),
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
    final String emoji;
    final String message;

    if (type == 'DECLINED') {
      emoji = '📋';
      message = 'Tidak ada yang di-decline';
    } else if (type == 'VERIFIED') {
      emoji = '✅';
      message = 'Semua teknisi terverifikasi';
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
          Text(
            message,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(Map<String, dynamic> tech) {
    final status = tech['status'] as String;
    final Color statusColor;
    if (status == 'VERIFIED') {
      statusColor = _colorVerified;
    } else if (status == 'DECLINED') {
      statusColor = _colorDeclined;
    } else {
      statusColor = _colorPending;
    }

    final List<String> categories = List<String>.from(tech['categories']);

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.adminVerification),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  tech['initials'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tech['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tech['city']}  ·  ${tech['workshop']}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: categories.map(_buildChip).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submitted: ${tech['submitted']}',
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
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
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../services/technician_service.dart';

class TechnicianListPage extends StatefulWidget {
  const TechnicianListPage({super.key});

  @override
  State<TechnicianListPage> createState() => _TechnicianListPageState();
}

class _TechnicianListPageState extends State<TechnicianListPage> {
  final TechnicianService _service = TechnicianService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<TechnicianOnlineModel> _all = [];
  bool _isLoading = true;
  String? _errorMessage;

  // ── Filter state ──────────────────────────────────────────────
  String _searchQuery = '';
  String? _selectedCategory; // null = semua
  double _minRating = 0;    // 0 = semua rating

  static const _categoryFilters = [
    {'label': 'Semua',    'value': null},
    {'label': 'Handphone','value': 'electronic'},
    {'label': 'Kendaraan','value': 'vehicle'},
  ];

  static const _ratingFilters = [
    {'label': 'Semua',  'value': 0.0},
    {'label': '★ 4.0+', 'value': 4.0},
    {'label': '★ 4.5+', 'value': 4.5},
  ];

  List<TechnicianOnlineModel> get _filtered {
    return _all.where((t) {
      final q = _searchQuery.toLowerCase();
      final matchQ = q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.specialty.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
      final matchCat = _selectedCategory == null ||
          t.category == _selectedCategory;
      final matchRating = t.rating >= _minRating;
      return matchQ && matchCat && matchRating;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Baca kategori dari args (dikirim dari home page categories)
    final args = Get.arguments;
    if (args is Map && args['category'] != null) {
      _selectedCategory = args['category'] as String;
    }
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text);
    });
    _loadTechnicians();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTechnicians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _service.getCurrentLocation();

      if (position == null) {
        setState(() {
          _errorMessage = 'Izin lokasi diperlukan untuk mencari teknisi terdekat.';
          _isLoading = false;
        });
        return;
      }

      final technicians = await _service.getTechnicianList(
        lat: position.latitude,
        lng: position.longitude,
        radiusKm: 50, // perluas radius supaya tidak kosong
      );

      setState(() {
        _all = technicians;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data teknisi. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildFilters(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildSkeleton();

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded,
                  size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTechnicians,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final results = _filtered;

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Tidak ada teknisi untuk\n"$_searchQuery"'
                    : 'Tidak ada teknisi tersedia\ndi area kamu saat ini.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_searchQuery.isNotEmpty || _selectedCategory != null || _minRating > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    onPressed: () => setState(() {
                      _searchCtrl.clear();
                      _selectedCategory = null;
                      _minRating = 0;
                    }),
                    child: const Text('Reset Filter'),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTechnicians,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        itemCount: results.length + 1,
        itemBuilder: (context, index) {
          if (index == results.length) {
            return const SizedBox(height: 120);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _TechnicianCard(technician: results[index]),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _SkeletonCard(),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            splashRadius: 24,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Find Technicians',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Cari teknisi atau jenis perbaikan...',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () => _searchCtrl.clear(),
                child: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.close_rounded,
                      color: Color(0xFF94A3B8), size: 20),
                ),
              ),
            Container(
              margin: const EdgeInsets.all(6),
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // ── Kategori chips ──────────────────────────────────
          ..._categoryFilters.map((f) {
            final val = f['value'];
            final isSelected = _selectedCategory == val;
            return _ActiveFilterChip(
              label: f['label'] as String,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedCategory = val),
            );
          }),
          const SizedBox(width: 8),
          // ── Rating chips ────────────────────────────────────
          ..._ratingFilters.skip(1).map((f) {
            final val = (f['value'] as double);
            final isSelected = _minRating == val;
            return _ActiveFilterChip(
              label: f['label'] as String,
              isSelected: isSelected,
              onTap: () => setState(() => _minRating = isSelected ? 0 : val),
            );
          }),
        ],
      ),
    );
  }
}

// ── Skeleton Card ──────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final c = Colors.grey.withValues(alpha: _anim.value);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _box(c, w: 72, h: 72, r: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _box(c, w: 140, h: 18),
                          const SizedBox(height: 8),
                          _box(c, w: 100, h: 14),
                          const SizedBox(height: 10),
                          _box(c, w: 80, h: 24, r: 6),
                        ],
                      ),
                    ),
                    _box(c, w: 44, h: 56, r: 12),
                  ],
                ),
              ),
              Container(
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _box(c, w: 80, h: 24),
                    _box(c, w: 100, h: 40, r: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _box(Color c,
      {required double w, required double h, double r = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

// ── Technician Card (pakai real data) ─────────────────────────────

class _TechnicianCard extends StatelessWidget {
  final TechnicianOnlineModel technician;

  const _TechnicianCard({required this.technician});

  String get _statusBadge {
    if (technician.rating >= 4.8) return 'PRO';
    if (technician.totalJobs >= 10) return 'VERIFIED';
    return 'RISING STAR';
  }

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeTextColor;
    switch (_statusBadge) {
      case 'PRO':
        badgeColor = const Color(0xFFDAE6FF);
        badgeTextColor = const Color(0xFF1E40AF);
        break;
      case 'VERIFIED':
        badgeColor = const Color(0xFFFFDAB9).withValues(alpha: 0.5);
        badgeTextColor = const Color(0xFF92400E);
        break;
      default:
        badgeColor = const Color(0xFFE2E8F0);
        badgeTextColor = const Color(0xFF475569);
    }

    // Harga dari serviceEstimate pertama kalau ada
    final String priceLabel = technician.serviceEstimates.isNotEmpty
        ? technician.serviceEstimates.first.priceLabel
        : 'Hubungi';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: technician.photoUrl != null &&
                          technician.photoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            technician.photoUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.person_rounded,
                          color: Color(0xFF94A3B8), size: 32),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        technician.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${technician.specialty} • ${technician.yearsExperience} yrs',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _statusBadge,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: badgeTextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on_rounded,
                              size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            technician.distanceLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFF0061FF), size: 20),
                      const SizedBox(height: 2),
                      Text(
                        technician.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Price & Book Now
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED PRICE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0056FF),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed(
                    AppRoutes.technicianDetail,
                    arguments: technician,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active Filter Chip ─────────────────────────────────────────────

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActiveFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
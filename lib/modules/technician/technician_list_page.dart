import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox
    if (dart.library.html) '../../config/mapbox_web_stub.dart';

import '../../config/routes.dart';
import '../../services/technician_service.dart';

// ── Palette ───────────────────────────────────────────────────────────────
const Color _ink  = Color(0xFF0F172A);
const Color _muted= Color(0xFF64748B);
const Color _blue = Color(0xFF0061FF);

class TechnicianListPage extends StatefulWidget {
  const TechnicianListPage({super.key});

  @override
  State<TechnicianListPage> createState() => _TechnicianListPageState();
}

class _TechnicianListPageState extends State<TechnicianListPage> {
  final TechnicianService _service = TechnicianService();
  final TextEditingController _searchCtrl = TextEditingController();
  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();

  List<TechnicianOnlineModel> _all = [];
  bool _isLoading = true;
  String? _errorMessage;

  // ── Filter state ─────────────────────────────────────────────────────────
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'distance'; // 'distance' | 'rating' | 'jobs'

  static const _categoryFilters = [
    {'label': 'Semua',     'value': null},
    {'label': 'Handphone', 'value': 'electronic'},
    {'label': 'Kendaraan', 'value': 'vehicle'},
  ];

  static const _sortOptions = [
    {'label': 'Terdekat',  'icon': Icons.near_me_rounded,       'value': 'distance'},
    {'label': 'Rating',    'icon': Icons.star_rounded,           'value': 'rating'},
    {'label': 'Terpopuler','icon': Icons.workspace_premium_rounded,'value': 'jobs'},
  ];

  List<TechnicianOnlineModel> get _filtered {
    var list = _all.where((t) {
      final q = _searchQuery.toLowerCase();
      final matchQ = q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.specialty.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
      final matchCat =
          _selectedCategory == null || t.category == _selectedCategory;
      return matchQ && matchCat;
    }).toList();

    switch (_sortBy) {
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'jobs':
        list.sort((a, b) => b.totalJobs.compareTo(a.totalJobs));
      default: // 'distance'
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return list;
  }

  // ── Map ──────────────────────────────────────────────────────────────────
  mapbox.MapboxMap? _mapboxMap;
  mapbox.CircleAnnotationManager? _circleManager;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
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
    _sheetCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> _loadTechnicians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _service.getCurrentLocation();

      // Pakai koordinat GPS kalau ada, fallback ke default (Makassar)
      final lat = position?.latitude ?? -5.1477;
      final lng = position?.longitude ?? 119.4327;

      if (!mounted) return;
      setState(() {
        _userLat = lat;
        _userLng = lng;
      });

      // Fly map ke lokasi user
      await _mapboxMap?.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
          zoom: 12.0,
        ),
        mapbox.MapAnimationOptions(duration: 800),
      );

      final technicians = await _service.getTechnicianList(
        lat: lat,
        lng: lng,
        radiusKm: 9999, // fetch semua, filter nanti
      );

      if (!mounted) return;
      setState(() {
        _all = technicians;
        _isLoading = false;
      });

      _addTechnicianMarkers(technicians);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load technicians. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addTechnicianMarkers(List<TechnicianOnlineModel> techs) async {
    if (_circleManager == null) return;
    await _circleManager!.deleteAll();

    final options = techs
        .where((t) => t.lat != null && t.lng != null)
        .map((t) => mapbox.CircleAnnotationOptions(
              geometry: mapbox.Point(
                  coordinates: mapbox.Position(t.lng!, t.lat!)),
              circleRadius: 9.0,
              circleColor: 0xFF0061FF,
              circleStrokeWidth: 2.5,
              circleStrokeColor: 0xFFFFFFFF,
            ))
        .toList();

    if (options.isNotEmpty) {
      await _circleManager!.createMulti(options);
    }
  }

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    _mapboxMap = map;

    // Disable gestures (map hanya dekorasi — user bisa ketuk tombol untuk expand)
    await map.gestures.updateSettings(mapbox.GesturesSettings(
      scrollEnabled: true,
      rotateEnabled: false,
      pitchEnabled: false,
      pinchToZoomEnabled: true,
      doubleTapToZoomInEnabled: true,
    ));

    // Location puck
    await map.location.updateSettings(
      mapbox.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    _circleManager = await map.annotations.createCircleAnnotationManager();

    // Fly ke lokasi user jika sudah tersedia
    if (_userLat != null && _userLng != null) {
      await map.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
              coordinates: mapbox.Position(_userLng!, _userLat!)),
          zoom: 12.0,
        ),
        mapbox.MapAnimationOptions(duration: 0),
      );
    }

    // Tambah marker kalau data sudah ada
    if (_all.isNotEmpty) _addTechnicianMarkers(_all);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 1. MAP (full screen background) ──────────────────────
          Positioned.fill(
            child: mapbox.MapWidget(
              key: const ValueKey('technician_list_map'),
              styleUri: mapbox.MapboxStyles.DARK,
              cameraOptions: mapbox.CameraOptions(
                center: mapbox.Point(
                  coordinates: mapbox.Position(
                    _userLng ?? 119.4327,
                    _userLat ?? -5.1477,
                  ),
                ),
                zoom: 11.5,
              ),
              onMapCreated: _onMapCreated,
            ),
          ),

          // ── 2. TOP OVERLAY (search + filters) ────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _TopSearchBar(
                  controller: _searchCtrl,
                  query: _searchQuery,
                ),
                const SizedBox(height: 8),
                _FilterRow(
                  filters: _categoryFilters,
                  selected: _selectedCategory,
                  onSelect: (v) => setState(() => _selectedCategory = v),
                ),
                const SizedBox(height: 6),
                _SortRow(
                  options: _sortOptions,
                  selected: _sortBy,
                  onSelect: (v) => setState(() => _sortBy = v),
                ),
              ],
            ),
          ),

          // ── 3. BOTTOM SHEET (technician list) ────────────────────
          DraggableScrollableSheet(
            controller: _sheetCtrl,
            initialChildSize: 0.42,
            minChildSize: 0.18,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.18, 0.42, 0.88],
            builder: (context, scrollCtrl) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F3F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ── Drag handle ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // ── Header ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nearby Technicians',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: _ink,
                                  ),
                                ),
                                if (!_isLoading)
                                  Text(
                                    '${_filtered.length} professional expert${_filtered.length == 1 ? '' : 's'} currently active',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _muted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _sheetCtrl.animateTo(
                              0.88,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Content ──────────────────────────────────
                    Expanded(
                      child: _isLoading
                          ? _buildSkeleton(scrollCtrl)
                          : _errorMessage != null
                              ? _buildError(scrollCtrl)
                              : _filtered.isEmpty
                                  ? _buildEmpty(scrollCtrl)
                                  : _buildList(scrollCtrl),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(ScrollController ctrl) {
    final results = _filtered;
    return ListView.builder(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: results.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _TechnicianCard(technician: results[i]),
      ),
    );
  }

  Widget _buildSkeleton(ScrollController ctrl) {
    return ListView.builder(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: 3,
      itemBuilder: (context2, index2) => const Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: _SkeletonCard(),
      ),
    );
  }

  Widget _buildError(ScrollController ctrl) {
    return SingleChildScrollView(
      controller: ctrl,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_rounded, size: 44, color: _muted),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadTechnicians,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ScrollController ctrl) {
    return SingleChildScrollView(
      controller: ctrl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 44, color: _muted),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No technicians found for "$_searchQuery"'
                  : 'No technicians available.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13),
            ),
            if (_searchQuery.isNotEmpty || _selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: TextButton(
                  onPressed: () => setState(() {
                    _searchCtrl.clear();
                    _selectedCategory = null;
                  }),
                  child: const Text('Reset Filter'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TOP SEARCH BAR
// ════════════════════════════════════════════════════════════════════════════
class _TopSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  const _TopSearchBar({required this.controller, required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          // ── Back button ─────────────────────────────────────────
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 8),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: _ink,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // ── Search box ──────────────────────────────────────────
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      color: Color(0xFF94A3B8), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                          fontSize: 13, color: _ink, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Search for hardware repair...',
                        hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (query.isNotEmpty)
                    GestureDetector(
                      onTap: () => controller.clear(),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.close_rounded,
                            color: Color(0xFF94A3B8), size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FILTER ROW (horizontal chips)
// ════════════════════════════════════════════════════════════════════════════
class _FilterRow extends StatelessWidget {
  final List<Map<String, dynamic>> filters;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final val = f['value'] as String?;
          final isSelected = selected == val;
          return GestureDetector(
            onTap: () => onSelect(val),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.4),
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                            color: Color(0x22000000), blurRadius: 8)
                      ]
                    : null,
              ),
              child: Text(
                f['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? _ink : Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SORT ROW
// ════════════════════════════════════════════════════════════════════════════
class _SortRow extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _SortRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          const Text(
            'Sort:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
          ...options.map((opt) {
            final val = opt['value'] as String;
            final isSelected = selected == val;
            return GestureDetector(
              onTap: () => onSelect(val),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0061FF)
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      opt['icon'] as IconData,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      opt['label'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TECHNICIAN CARD
// ════════════════════════════════════════════════════════════════════════════
class _TechnicianCard extends StatelessWidget {
  final TechnicianOnlineModel technician;
  const _TechnicianCard({required this.technician});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.technicianDetail,
        arguments: technician,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ─────────────────────────────────────────
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: technician.photoUrl != null &&
                      technician.photoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        technician.photoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.person_rounded,
                      color: Color(0xFF94A3B8), size: 28),
            ),
            const SizedBox(width: 12),

            // ── Info ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    technician.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // ── Rating stars ──────────────────────────
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < technician.rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 12,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        technician.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // ── Tags ─────────────────────────────────
                  Wrap(
                    spacing: 5,
                    children: [
                      _SmallTag(
                        label: technician.specialty.isEmpty
                            ? technician.category.toUpperCase()
                            : technician.specialty.toUpperCase(),
                        color: const Color(0xFFDCEDFF),
                        textColor: const Color(0xFF1D4ED8),
                      ),
                      _SmallTag(
                        label: technician.distanceLabel,
                        color: const Color(0xFFF1F5F9),
                        textColor: _muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Book Now button ─────────────────────────────────
            GestureDetector(
              onTap: () => Get.toNamed(
                AppRoutes.technicianDetail,
                arguments: technician,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _SmallTag(
      {required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SKELETON CARD
// ════════════════════════════════════════════════════════════════════════════
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

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
      builder: (context2, child) {
        final c = Colors.grey.withValues(alpha: _anim.value);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _box(c, w: 60, h: 60, r: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(c, w: 120, h: 14),
                    const SizedBox(height: 8),
                    _box(c, w: 80, h: 10),
                    const SizedBox(height: 8),
                    _box(c, w: 100, h: 10),
                  ],
                ),
              ),
              _box(c, w: 72, h: 34, r: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _box(Color c, {required double w, required double h, double r = 8}) {
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

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart' hide Position;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    if (dart.library.html) '../../config/mapbox_web_stub.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../services/technician_service.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      extendBody: true,
      bottomNavigationBar: const CustomerNavBar(selectedItem: AppNavItem.home),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => controller.loadNearbyTechnicians(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ELECTROVICE_LOGO_HD.png',
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF1E293B),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Hero CTA Card ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _HeroCTACard(),
                ),

                const SizedBox(height: 16),

                // ── Search Bar ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _SearchBar(),
                ),

                const SizedBox(height: 16),

                // ── Current Repair ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Obx(() => controller.isLoadingTechnicians.value
                      ? const _CurrentRepairSkeleton()
                      : const _CurrentRepairCard()),
                ),

                const SizedBox(height: 12),

                // ── Repair Categories ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Obx(() => controller.isLoadingTechnicians.value
                        ? const _CategoriesSkeleton()
                        : const _RepairCategories()),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Featured Specialists ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _FeaturedSpecialistsSection(),
                ),

                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HERO CTA CARD  (live Mapbox map + gradient overlay)
// ═══════════════════════════════════════════════════════════════
class _HeroCTACard extends StatefulWidget {
  @override
  State<_HeroCTACard> createState() => _HeroCTACardState();
}

class _HeroCTACardState extends State<_HeroCTACard> {
  MapboxMap? _mapboxMap;

  // Default: Makassar
  double _lat = -5.1477;
  double _lng = 119.4327;
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _locationReady = true;
      });

      await _mapboxMap?.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(_lng, _lat)),
          zoom: 13.5,
          padding: MbxEdgeInsets(top: 0, left: 0, bottom: 80, right: 0),
        ),
        MapAnimationOptions(duration: 1000),
      );
    } catch (_) {}
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Disable all touch interactions — purely decorative
    await mapboxMap.gestures.updateSettings(
      GesturesSettings(
        scrollEnabled: false,
        rotateEnabled: false,
        pitchEnabled: false,
        pinchToZoomEnabled: false,
        doubleTapToZoomInEnabled: false,
        doubleTouchToZoomOutEnabled: false,
        quickZoomEnabled: false,
      ),
    );

    // Hide logo & attribution
    await mapboxMap.logo.updateSettings(LogoSettings(enabled: false));
    await mapboxMap.attribution.updateSettings(
      AttributionSettings(enabled: false),
    );
    await mapboxMap.scaleBar.updateSettings(
      ScaleBarSettings(enabled: false),
    );

    // Show user location puck
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    // Fly to user location if already fetched before map was ready
    if (_locationReady) {
      await mapboxMap.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(_lng, _lat)),
          zoom: 13.5,
          padding: MbxEdgeInsets(top: 0, left: 0, bottom: 80, right: 0),
        ),
        MapAnimationOptions(duration: 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.technicianList),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF0D1117),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Live Mapbox map ──────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox.expand(
                child: MapWidget(
                  key: const ValueKey('home_hero_map'),
                  styleUri: MapboxStyles.DARK,
                  cameraOptions: CameraOptions(
                    center: Point(coordinates: Position(_lng, _lat)),
                    zoom: 13.0,
                    padding: MbxEdgeInsets(
                      top: 0,
                      left: 0,
                      bottom: 80,
                      right: 0,
                    ),
                  ),
                  onMapCreated: _onMapCreated,
                ),
              ),
            ),

            // ── Frosted glass pill — floating bottom ─────────────
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.hardEdge,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text block
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Find Nearby\nTechnicians',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '12 active specialists\navailable now',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color.fromARGB(255, 33, 34, 36),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Explore Map button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Explore Map',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ═══════════════════════════════════════════════════════════════
//  SEARCH BAR
// ═══════════════════════════════════════════════════════════════
class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _search() {
    final query = _controller.text.trim();
    Get.toNamed(AppRoutes.technicianList, arguments: {'query': query});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _search(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                hintText: 'Search for hardware repair...',
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 112, 117, 121),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: _search,
            child: Container(
              margin: const EdgeInsets.all(6),
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CURRENT REPAIR CARD  (matches Figma: IN PROGRESS badge)
// ═══════════════════════════════════════════════════════════════
class _CurrentRepairCard extends StatelessWidget {
  const _CurrentRepairCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.orderTracking),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT REPAIR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'MacBook Pro M1 • Screen Replacement',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'IN PROGRESS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  REPAIR CATEGORIES  (matches Figma: TV & AUDIO, COMPUTERS, etc)
// ═══════════════════════════════════════════════════════════════
class _RepairCategories extends StatelessWidget {
  const _RepairCategories();

  static const _mainCategories = [
    {'icon': Icons.tv_rounded, 'label': 'TV & AUDIO', 'category': 'electronic'},
    {
      'icon': Icons.laptop_rounded,
      'label': 'COMPUTERS',
      'category': 'electronic',
    },
    {
      'icon': Icons.kitchen_rounded,
      'label': 'APPLIANCES',
      'category': 'electronic',
    },
    {
      'icon': Icons.directions_car_rounded,
      'label': 'VEHICLES',
      'category': 'vehicle',
    },
  ];

  static const _moreCategories = [
    {
      'icon': Icons.ac_unit_rounded,
      'label': 'AC & COOLING',
      'category': 'electronic',
    },
    {
      'icon': Icons.phone_android_rounded,
      'label': 'SMARTPHONES',
      'category': 'electronic',
    },
    {
      'icon': Icons.electrical_services_rounded,
      'label': 'ELECTRICAL',
      'category': 'electronic',
    },
    {
      'icon': Icons.water_drop_rounded,
      'label': 'PLUMBING',
      'category': 'electronic',
    },
    {
      'icon': Icons.camera_alt_rounded,
      'label': 'CAMERAS',
      'category': 'electronic',
    },
    {'icon': Icons.speaker_rounded, 'label': 'AUDIO', 'category': 'electronic'},
    {
      'icon': Icons.router_rounded,
      'label': 'NETWORKING',
      'category': 'electronic',
    },
    {'icon': Icons.build_rounded, 'label': 'OTHERS', 'category': 'electronic'},
  ];

  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [..._mainCategories, ..._moreCategories]
                  .map(
                    (c) => _CategoryItem(
                      icon: c['icon'] as IconData,
                      label: c['label'] as String,
                      category: c['category'] as String,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Repair Categories',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            GestureDetector(
              onTap: () => _showAllCategories(context),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _mainCategories
              .map(
                (c) => _CategoryItem(
                  icon: c['icon'] as IconData,
                  label: c['label'] as String,
                  category: c['category'] as String,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String category;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.technicianList,
        arguments: {'category': category},
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  FEATURED SPECIALISTS SECTION
// ═══════════════════════════════════════════════════════════════
class _FeaturedSpecialistsSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Specialists',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.technicianList),
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (controller.isLoadingTechnicians.value) {
            return Column(
              children: List.generate(
                2,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _TechnicianCardSkeleton(),
                ),
              ),
            );
          }

          if (controller.locationError.value.isNotEmpty) {
            return _ErrorState(
              message: controller.locationError.value,
              onRetry: controller.loadNearbyTechnicians,
            );
          }

          if (controller.nearbyTechnicians.isEmpty) {
            return _EmptyState(
              onExplore: () => Get.toNamed(AppRoutes.technicianList),
            );
          }

          return Column(
            children: controller.nearbyTechnicians
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TechnicianCard(technician: t),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }
}

// ── Technician Card ────────────────────────────────────────────
class _TechnicianCard extends StatelessWidget {
  final TechnicianOnlineModel technician;
  const _TechnicianCard({required this.technician});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.technicianDetail, arguments: technician),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  technician.photoUrl != null && technician.photoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        technician.photoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF94A3B8),
                      size: 32,
                    ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    technician.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    technician.specialty.isEmpty
                        ? technician.category.toUpperCase()
                        : technician.specialty.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D4ED8),
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        technician.distanceLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (technician.totalJobs >= 200) ...[
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(color: Color(0xFFCBD5E1)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${technician.totalJobs}+ Jobs',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Rating badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Color(0xFF0061FF),
                  ),
                  const SizedBox(width: 4),
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
    );
  }
}

// ── Shimmer Skeleton ─────────────────────────────────────────────
class _TechnicianCardSkeleton extends StatefulWidget {
  const _TechnicianCardSkeleton();

  @override
  State<_TechnicianCardSkeleton> createState() =>
      _TechnicianCardSkeletonState();
}

class _TechnicianCardSkeletonState extends State<_TechnicianCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
      builder: (context, child) {
        final shimmerColor = Color.lerp(
          const Color(0xFFE2E8F0),
          const Color(0xFFF8FAFC),
          _anim.value,
        )!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _box(shimmerColor, w: 68, h: 68, r: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(shimmerColor, w: 130, h: 14),
                    const SizedBox(height: 8),
                    _box(shimmerColor, w: 90, h: 10),
                    const SizedBox(height: 10),
                    _box(shimmerColor, w: 110, h: 11),
                  ],
                ),
              ),
              _box(shimmerColor, w: 50, h: 32, r: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _box(
    Color color, {
    required double w,
    required double h,
    double r = 6,
  }) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

// ── Current Repair Skeleton ──────────────────────────────────────
class _CurrentRepairSkeleton extends StatefulWidget {
  const _CurrentRepairSkeleton();

  @override
  State<_CurrentRepairSkeleton> createState() => _CurrentRepairSkeletonState();
}

class _CurrentRepairSkeletonState extends State<_CurrentRepairSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
      builder: (_, child) {
        final c = Color.lerp(
          const Color(0xFFBFCFFF),
          const Color(0xFFD9E4FF),
          _anim.value,
        )!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 10,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 160,
                      height: 13,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 26,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Categories Skeleton ───────────────────────────────────────────
class _CategoriesSkeleton extends StatefulWidget {
  const _CategoriesSkeleton();

  @override
  State<_CategoriesSkeleton> createState() => _CategoriesSkeletonState();
}

class _CategoriesSkeletonState extends State<_CategoriesSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
      builder: (_, child) {
        final c = Color.lerp(
          const Color(0xFFE2E8F0),
          const Color(0xFFF8FAFC),
          _anim.value,
        )!;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 130,
                  height: 14,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (_) {
                return Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 48,
                      height: 8,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onExplore;
  const _EmptyState({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada teknisi tersedia\ndi area kamu saat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onExplore,
            child: const Text(
              'Cari di radius lebih luas →',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF0061FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error State ─────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(
            Icons.location_off_rounded,
            size: 40,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Coba lagi',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF0061FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

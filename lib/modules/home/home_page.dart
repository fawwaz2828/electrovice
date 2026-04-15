import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart' hide Position;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    if (dart.library.html) '../../config/mapbox_web_stub.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';
import '../../services/technician_service.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../booking/booking_controller.dart';
import '../notification/notification_controller.dart';
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
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      Row(
                        children: [
                          _HeaderIconButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            onTap: () => Get.toNamed(AppRoutes.chatInbox),
                          ),
                          const SizedBox(width: 8),
                          _NotifBell(),
                        ],
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

                // ── Current Repair Card ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const _CurrentRepairCard(),
                ),

                const SizedBox(height: 22),

                // ── Repair Categories ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const _RepairCategories(),
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

// ── Header Icon Button ─────────────────────────────────────────────────────
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _HeaderIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Icon(icon, color: const Color(0xFF1E293B), size: 20),
      ),
    );
  }
}

// ── Notification Bell with Badge ──────────────────────────────────────────
class _NotifBell extends StatelessWidget {
  _NotifBell();

  final _notifCtrl = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.notifications),
      child: Obx(() {
        final count = _notifCtrl.unreadCount.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
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
              child: const Icon(Icons.notifications_none_rounded,
                  color: Color(0xFF1E293B), size: 20),
            ),
            if (count > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      }),
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
        height: 190,
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
                  styleUri: MapboxStyles.OUTDOORS,
                  cameraOptions: CameraOptions(
                    center: Point(
                      coordinates: Position(_lng, _lat),
                    ),
                    zoom: 13.0,
                  ),
                  onMapCreated: _onMapCreated,
                ),
              ),
            ),

            // ── Gradient overlay (left-heavy, matches Figma) ─────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xEE0D1117),
                    Color(0xAA0D1117),
                    Color(0x440D1117),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.4, 0.65, 1.0],
                ),
              ),
            ),

            // ── Text content (bottom-left) ───────────────────────
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Find Nearby\nTechnicians',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    final ctrl = Get.find<HomeController>();
                    final count = ctrl.technicianCount.value;
                    final label = count > 0
                        ? '$count active specialists\navailable now'
                        : 'Find specialists\nnear you';
                    return Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.explore_rounded,
                            size: 14, color: Color(0xFF0D1117)),
                        SizedBox(width: 6),
                        Text(
                          'Explore Map',
                          style: TextStyle(
                            color: Color(0xFF0D1117),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

// ═══════════════════════════════════════════════════════════════
//  SEARCH BAR
// ═══════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.technicianList),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            const Icon(Icons.search_rounded,
                color: Color(0xFFADB5BD), size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Search for hardware repair...',
                style: TextStyle(
                  color: Color(0xFFADB5BD),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CURRENT REPAIR CARD  — data dari BookingController
// ═══════════════════════════════════════════════════════════════
class _CurrentRepairCard extends GetView<BookingController> {
  const _CurrentRepairCard();

  String _statusLabel(String status) => switch (status) {
        BookingStatus.pending => 'MENUNGGU',
        BookingStatus.confirmed => 'DIKONFIRMASI',
        BookingStatus.onProgress => 'IN PROGRESS',
        BookingStatus.awaitingPayment => 'BAYAR',
        BookingStatus.done => 'SELESAI',
        _ => 'IN PROGRESS',
      };

  Color _statusBg(String status) => switch (status) {
        BookingStatus.pending => const Color(0xFFFFF7ED),
        BookingStatus.awaitingPayment => const Color(0xFFFFF1F2),
        BookingStatus.done => const Color(0xFFDCFCE7),
        _ => const Color(0xFFDCEDFF),
      };

  Color _statusTextColor(String status) => switch (status) {
        BookingStatus.pending => const Color(0xFFD97706),
        BookingStatus.awaitingPayment => const Color(0xFFE11D48),
        BookingStatus.done => const Color(0xFF16A34A),
        _ => const Color(0xFF0061FF),
      };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final booking = controller.activeBooking.value;

      // Tidak ada active booking — sembunyikan card
      if (booking == null) return const SizedBox.shrink();

      final title =
          '${booking.technicianName} • ${_damageTypeLabel(booking.damageType)}';
      final status = booking.status;

      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.orderTracking),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.build_rounded,
                    color: Color(0xFF475569), size: 20),
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
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
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
                  color: _statusBg(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: _statusTextColor(status),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _damageTypeLabel(String type) => switch (type) {
        'screen' => 'Layar',
        'battery' => 'Baterai',
        'hardware' => 'Hardware',
        'water' => 'Water Damage',
        'camera' => 'Kamera',
        _ => 'Perbaikan Umum',
      };
}

// ═══════════════════════════════════════════════════════════════
//  REPAIR CATEGORIES  (matches Figma: TV & AUDIO, COMPUTERS, etc)
// ═══════════════════════════════════════════════════════════════
class _RepairCategories extends StatelessWidget {
  const _RepairCategories();

  static const _categories = [
    {'icon': Icons.phone_android_rounded, 'label': 'HANDPHONE', 'category': 'electronic'},
    {'icon': Icons.laptop_rounded,        'label': 'KOMPUTER',  'category': 'electronic'},
    {'icon': Icons.tv_rounded,            'label': 'TV & AUDIO','category': 'electronic'},
    {'icon': Icons.kitchen_rounded,       'label': 'ELEKTRONIK','category': 'electronic'},
    {'icon': Icons.ac_unit_rounded,       'label': 'AC / KULKAS','category': 'electronic'},
    {'icon': Icons.directions_car_rounded,'label': 'KENDARAAN', 'category': 'vehicle'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kategori Layanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.technicianList),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0061FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2 baris × 3 kolom
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 0,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (_, i) {
              final c = _categories[i];
              return _CategoryItem(
                icon: c['icon'] as IconData,
                label: c['label'] as String,
                category: c['category'] as String,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String category;
  const _CategoryItem(
      {required this.icon, required this.label, required this.category});

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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF475569), size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
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
                  color: Color(0xFF0061FF),
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
                .map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TechnicianCard(technician: t),
                    ))
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
      onTap: () => Get.toNamed(
        AppRoutes.technicianDetail,
        arguments: technician,
      ),
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
              child: technician.photoUrl != null &&
                      technician.photoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(technician.photoUrl!,
                          fit: BoxFit.cover),
                    )
                  : const Icon(Icons.person_rounded,
                      color: Color(0xFF94A3B8), size: 32),
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
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: Color(0xFF94A3B8)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 14, color: Color(0xFF0061FF)),
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
      builder: (context, child) {
        final shimmerColor =
            Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFF8FAFC),
                _anim.value)!;
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

  Widget _box(Color color,
      {required double w, required double h, double r = 6}) {
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
          const Icon(Icons.search_off_rounded,
              size: 48, color: Color(0xFF94A3B8)),
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
          const Icon(Icons.location_off_rounded,
              size: 40, color: Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
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

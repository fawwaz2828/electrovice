import 'dart:ui';
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
      backgroundColor: Colors.white,
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
                          _NotifBell(),
                          const SizedBox(width: 8),
                          _HeaderIconButton(
                            icon: Icons.send_rounded,
                            onTap: () => Get.toNamed(AppRoutes.chatInbox),
                          ),
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
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF0A0A0A), width: 1.5),
                    ),
                    child: const _RepairCategories(),
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
              color: const Color(0xFF0A0A0A).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Color(0xFF1E293B), size: 20),
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
                    color: const Color(0xFF0A0A0A).withValues(alpha: 0.06),
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
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF0D1117),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF0A0A0A).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // ── Live Mapbox map (full bleed) ─────────────────
              SizedBox.expand(
                child: MapWidget(
                  key: const ValueKey('home_hero_map'),
                  styleUri: MapboxStyles.DARK,
                  cameraOptions: CameraOptions(
                    center: Point(
                      coordinates: Position(_lng, _lat),
                    ),
                    zoom: 13.0,
                  ),
                  onMapCreated: _onMapCreated,
                ),
              ),

              // ── Glassmorphism panel (bottom) ─────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Color(0xFF1C1C1E).withValues(alpha: 0.65),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Text ──────────────────────────
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Find Nearby\nTechnicians',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(() {
                                  final ctrl = Get.find<HomeController>();
                                  final count = ctrl.technicianCount.value;
                                  final label = count > 0
                                      ? '$count active specialists available now'
                                      : 'Find specialists near you';
                                  return Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFADB5BD),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ── Explore Map button ─────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.explore_rounded,
                                    size: 14, color: Color(0xFF0D1117)),
                                SizedBox(width: 5),
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
                  ),
                ),
              ),
            ],
          ),
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
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFF0A0A0A), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A0A0A).withValues(alpha: 0.06),
              blurRadius: 10,
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
              decoration: const BoxDecoration(
                color: Color(0xFF0A0A0A),
                shape: BoxShape.circle,
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

  static String _statusLabel(String status) => switch (status) {
        BookingStatus.pending => 'PENDING',
        BookingStatus.confirmed => 'CONFIRMED',
        BookingStatus.onProgress => 'IN PROGRESS',
        BookingStatus.awaitingPayment => 'PAY',
        BookingStatus.done => 'DONE',
        _ => 'IN PROGRESS',
      };

  static Color _statusBg(String status) => switch (status) {
        BookingStatus.pending => const Color(0xFFFFF7ED),
        BookingStatus.awaitingPayment => Color(0xFFFFF1F2),
        BookingStatus.done => const Color(0xFFDCFCE7),
        _ => Color(0xFF0061FF),
      };

  static Color _statusTextColor(String status) => switch (status) {
        BookingStatus.pending => const Color(0xFFD97706),
        BookingStatus.awaitingPayment => Color(0xFFE11D48),
        BookingStatus.done => const Color(0xFF16A34A),
        _ => Colors.white,
      };

  static String _damageTypeLabel(String type) => switch (type) {
        'screen' => 'Screen',
        'battery' => 'Battery',
        'hardware' => 'Hardware',
        'water' => 'Water Damage',
        'camera' => 'Camera',
        _ => 'General Repair',
      };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeBookings = controller.bookingHistory
          .where((b) => b.isActive)
          .toList();

      // No active bookings — hide section entirely
      if (activeBookings.isEmpty) return const SizedBox.shrink();

      return Column(
        children: activeBookings.map((booking) {
          final title =
              '${booking.technicianName} • ${booking.serviceName.isNotEmpty ? booking.serviceName : _damageTypeLabel(booking.damageType)}';
          final status = booking.status;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                final s = booking.status;
                if (s == BookingStatus.done || s == BookingStatus.cancelled) {
                  Get.toNamed(AppRoutes.bookingDetail, arguments: booking);
                } else {
                  controller.watchBooking(booking);
                  Get.toNamed(AppRoutes.orderTracking);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFF000000),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF0A0A0A), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.assignment_rounded,
                          color: Color(0xFF94A3B8), size: 20),
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
                              color: Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            style: const TextStyle(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusBg(status),
                        borderRadius: BorderRadius.circular(12),
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
            ),
          );
        }).toList(),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════
//  REPAIR CATEGORIES
// ═══════════════════════════════════════════════════════════════
class _RepairCategories extends StatelessWidget {
  const _RepairCategories();

  static const _categories = [
    {'icon': Icons.smartphone_rounded,     'label': 'SMARTPHONE', 'category': 'smartphone'},
    {'icon': Icons.laptop_rounded,         'label': 'LAPTOP',     'category': 'laptop'},
    {'icon': Icons.kitchen_rounded,        'label': 'APPLIANCE',  'category': 'appliance'},
    {'icon': Icons.directions_car_rounded, 'label': 'VEHICLE',    'category': 'vehicle'},
  ];

  static const _allCategories = [
    {'icon': Icons.smartphone_rounded,     'label': 'SMARTPHONE',  'category': 'smartphone'},
    {'icon': Icons.laptop_rounded,         'label': 'LAPTOP',      'category': 'laptop'},
    {'icon': Icons.kitchen_rounded,        'label': 'APPLIANCE',   'category': 'appliance'},
    {'icon': Icons.ac_unit_rounded,        'label': 'AC & COOLING','category': 'ac'},
    {'icon': Icons.tv_rounded,             'label': 'TV & DISPLAY','category': 'tv'},
    {'icon': Icons.directions_car_rounded, 'label': 'VEHICLE',     'category': 'vehicle'},
    {'icon': Icons.build_rounded,          'label': 'ELECTRONIC',  'category': 'electronic'},
    {'icon': Icons.memory_rounded,         'label': 'HARDWARE',    'category': 'hardware'},
  ];

  void _showAllSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.82,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              children: _allCategories.map((c) {
                return GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.toNamed(
                      AppRoutes.technicianList,
                      arguments: {'category': c['category']},
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF0A0A0A), width: 1.5),
                        ),
                        child: Icon(c['icon'] as IconData,
                            color: const Color(0xFF334155), size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            GestureDetector(
              onTap: () => _showAllSheet(context),
              child: const Text(
                'View All',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _categories.map((c) => _CategoryItem(
            icon: c['icon'] as IconData,
            label: c['label'] as String,
            category: c['category'] as String,
          )).toList(),
        ),
      ],
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
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0A0A0A), width: 1.5),
            ),
            child: Icon(icon, color: Color(0xFF334155), size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.2,
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
                      padding: const EdgeInsets.only(bottom: 16),
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
    final categoryLabel = technician.specialty.isNotEmpty
        ? technician.specialty.toUpperCase()
        : technician.category.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0A0A0A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A0A0A).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Circular avatar ──────────────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1F5F9),
            ),
            child: ClipOval(
              child: technician.photoUrl != null &&
                      technician.photoUrl!.isNotEmpty
                  ? Image.network(
                      technician.photoUrl!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.person_rounded,
                      color: Color(0xFF94A3B8), size: 36),
            ),
          ),
          const SizedBox(width: 14),

          // ── Info + button ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        technician.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A0A0A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 3),
                        Text(
                          technician.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Distance + category chip
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        categoryLabel,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D4ED8),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Book Now button
                GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.technicianDetail,
                    arguments: technician,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Book Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
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
            Color.lerp(const Color(0xFFE2E8F0), Color(0xFFF8FAFC),
                _anim.value)!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
            'No technicians available\nin your area right now.',
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
              'Search wider area →',
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
              'Try again',
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

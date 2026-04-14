import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../config/routes.dart';
import '../../utils/maps_launcher.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../technician/technician_controller.dart';

class JobDetailPage extends StatefulWidget {
  const JobDetailPage({super.key});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  bool _isAccepting = false;
  bool _isDeclining = false;

  String _damageLabel(String type) => switch (type) {
        'screen' => 'Kerusakan Layar',
        'battery' => 'Masalah Baterai',
        'hardware' => 'Kerusakan Hardware',
        'water' => 'Water Damage',
        'camera' => 'Masalah Kamera',
        _ => 'Perbaikan Umum',
      };

  String _formatPrice(int price) {
    final str = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  String _formatArrivalWindow(DateTime? dt) {
    if (dt == null) return '--:-- - --:--';
    final end = dt.add(const Duration(minutes: 90));
    String fmt(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '${fmt(dt)} - ${fmt(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TechnicianController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      extendBody: true,
      bottomNavigationBar: const TechnicianNavBar(selectedItem: AppNavItem.home),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // ── Top Bar ─────────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Status & Arrival Window ──────────────────────────────
              Obx(() {
                final order = controller.selectedOrder.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT STATE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0061FF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              order == null ? '-' : 'Permintaan Baru',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0061FF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'JADWAL KEDATANGAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatArrivalWindow(order?.scheduledAt),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),

              const SizedBox(height: 28),

              // ── Customer Profile Card ───────────────────────────────
              Obx(() {
                final order = controller.selectedOrder.value;
                final customerName = order?.userName ?? '-';
                return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _AvatarCard(imageUrl: null),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111111),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_rounded, color: Color(0xFF6F88AE), size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      (order?.userAddress.isNotEmpty ?? false)
                                          ? order!.userAddress
                                          : 'Alamat tidak tersedia',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6F88AE),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            final o = controller.selectedOrder.value;
                            return _ActionButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: 'MESSAGE',
                              color: const Color(0xFFF5F6FA),
                              textColor: const Color(0xFF111111),
                              onTap: o == null
                                  ? null
                                  : () => Get.toNamed(
                                        AppRoutes.chat,
                                        arguments: {
                                          'chatId': o.bookingId,
                                          'otherPartyName': o.userName,
                                          'bookingDoc': o,
                                        },
                                      ),
                            );
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.phone_outlined,
                            label: 'CALL',
                            color: const Color(0xFFF5F6FA),
                            textColor: const Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ); // end Container
              }), // end Obx

              const SizedBox(height: 16),

              // ── Map View Card ──────────────────────────────────────
              Obx(() {
                final order = controller.selectedOrder.value;
                final lat = order?.latitude;
                final lng = order?.longitude;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: lat != null && lng != null
                        ? _JobDetailMap(lat: lat, lng: lng)
                        : Container(
                            color: const Color(0xFFE8EDF5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_off_outlined,
                                    size: 28, color: Color(0xFF94A3B8)),
                                const SizedBox(height: 8),
                                Text(
                                  order?.userAddress.isNotEmpty == true
                                      ? order!.userAddress
                                      : 'Lokasi GPS tidak tersedia',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Color(0xFF64748B), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                  ),
                );
              }),

              // ── Navigate Button ────────────────────────────────────
              Obx(() {
                final order = controller.selectedOrder.value;
                final lat = order?.latitude;
                final lng = order?.longitude;
                if (lat == null || lng == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => MapsLauncher.navigateTo(
                        lat: lat,
                        lng: lng,
                        label: order?.userAddress,
                      ),
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: const Text(
                        'Navigasi ke Lokasi',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // ── Issue Identified Section ───────────────────────────
              Obx(() {
                final order = controller.selectedOrder.value;
                final issueTitle = _damageLabel(order?.damageType ?? '');
                final description = order?.description ?? '-';
                final categoryLabel = (order?.category ?? 'repair').toUpperCase();
                return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ISSUE IDENTIFIED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDD5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categoryLabel,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFC2410C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      issueTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
              }),

              const SizedBox(height: 16),

              // ── System Estimate Card ───────────────────────────────
              Obx(() {
                final order = controller.selectedOrder.value;
                final price = order?.estimatedPrice ?? 0;
                final priceLabel = price > 0 ? 'Rp ${_formatPrice(price)}' : 'Tunai';
                return Container(
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
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'System Estimate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL RANGE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            priceLabel,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0061FF),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Estimasi biaya (dapat berubah sesuai kondisi di lapangan)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ); // end Container
              }), // end Obx

              const SizedBox(height: 32),

              // ── Action Buttons ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isAccepting || _isDeclining
                          ? null
                          : () async {
                              setState(() => _isAccepting = true);
                              try {
                                await controller.acceptOrder();
                                Get.toNamed(AppRoutes.verification);
                              } catch (e) {
                                Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''),
                                    snackPosition: SnackPosition.BOTTOM);
                              } finally {
                                if (mounted) setState(() => _isAccepting = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: _isAccepting
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 20),
                                SizedBox(width: 10),
                                Text('Terima Order',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: _isAccepting || _isDeclining
                          ? null
                          : () async {
                              setState(() => _isDeclining = true);
                              try {
                                await controller.declineOrder();
                                Get.back();
                              } catch (e) {
                                Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''),
                                    snackPosition: SnackPosition.BOTTOM);
                              } finally {
                                if (mounted) setState(() => _isDeclining = false);
                              }
                            },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E8F0),
                        foregroundColor: const Color(0xFF475569),
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isDeclining
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close_rounded, size: 20),
                                SizedBox(width: 6),
                                Text('Tolak',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.textColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1E8DC),
            Color(0xFFE9EEF9),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 40,
          color: Color(0xFF505A69),
        ),
      ),
    );
  }
}

// ── Mapbox map untuk lokasi customer di job detail teknisi ──────────────────
class _JobDetailMap extends StatefulWidget {
  final double lat;
  final double lng;
  const _JobDetailMap({required this.lat, required this.lng});

  @override
  State<_JobDetailMap> createState() => _JobDetailMapState();
}

class _JobDetailMapState extends State<_JobDetailMap> {
  mapbox.CircleAnnotationManager? _circleManager;

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    _circleManager = await map.annotations.createCircleAnnotationManager();
    await _circleManager?.create(
      mapbox.CircleAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(widget.lng, widget.lat),
        ),
        circleRadius: 12.0,
        circleColor: 0xFF0061FF,
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return mapbox.MapWidget(
      key: const ValueKey('job_detail_map'),
      onMapCreated: _onMapCreated,
      cameraOptions: mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(widget.lng, widget.lat),
        ),
        zoom: 15.0,
      ),
    );
  }
}

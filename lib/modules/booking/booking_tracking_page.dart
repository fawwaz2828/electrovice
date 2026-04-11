import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../config/routes.dart';
<<<<<<< HEAD
import '../../models/booking_document.dart';
=======
>>>>>>> origin/main
import '../../models/booking_model.dart';
import '../../widget/app_bottom_nav_bar.dart';
import 'booking_controller.dart';

class BookingTrackingPage extends GetView<BookingController> {
  const BookingTrackingPage({super.key});

  static const Color _bg = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const CustomerNavBar(selectedItem: AppNavItem.order),
      body: SafeArea(
        child: Obx(() {
          final OrderTrackingData tracking = controller.trackingData;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order Tracking',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Icon(Icons.help_outline_rounded, color: Color(0xFF6E7789)),
                  ],
                ),
                const SizedBox(height: 16),
                _LiveMapCard(
                  title: tracking.mapTitle,
                  lat: tracking.customerLat,
                  lng: tracking.customerLng,
                ),
                const SizedBox(height: 14),
                _StatusCard(tracking: tracking),
                const SizedBox(height: 14),
                _SecurityCodeCard(
                  code: tracking.securityCode,
                  isPending: controller.activeBooking.value?.status ==
                      BookingStatus.pending,
                ),
                const SizedBox(height: 14),
                _TechnicianContactCard(
                  name: tracking.technicianName,
                  role: tracking.technicianRole,
                  partnerLabel: tracking.partnerLabel,
                  imageUrl: tracking.technicianAvatarUrl,
                  bookingDoc: controller.activeBooking.value,
                ),
                // ── Review prompt saat done ────────────────────
                if (controller.activeBooking.value?.status ==
                        BookingStatus.done &&
                    controller.activeBooking.value?.customerRating == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _ReviewBanner(
                      booking: controller.activeBooking.value!,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

}

class _LiveMapCard extends StatefulWidget {
  const _LiveMapCard({required this.title, this.lat, this.lng});

  final String title;
  final double? lat;
  final double? lng;

  @override
  State<_LiveMapCard> createState() => _LiveMapCardState();
}

class _LiveMapCardState extends State<_LiveMapCard> {
  mapbox.MapboxMap? _map;
  mapbox.CircleAnnotationManager? _circleManager;

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    _map = map;
    _circleManager = await map.annotations.createCircleAnnotationManager();
    if (widget.lat != null && widget.lng != null) {
      await _moveCameraAndPin(widget.lat!, widget.lng!);
    }
  }

  @override
  void didUpdateWidget(_LiveMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Koordinat berubah (misal dari Obx rebuild) — update peta
    if (widget.lat != oldWidget.lat || widget.lng != oldWidget.lng) {
      if (widget.lat != null && widget.lng != null) {
        _moveCameraAndPin(widget.lat!, widget.lng!);
      }
    }
  }

  Future<void> _moveCameraAndPin(double lat, double lng) async {
    if (_map == null) return;
    await _map!.flyTo(
      mapbox.CameraOptions(
        center: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
        zoom: 15.0,
      ),
      mapbox.MapAnimationOptions(duration: 800),
    );
    // Gunakan CircleAnnotation — tidak butuh icon asset eksternal
    await _circleManager?.deleteAll();
    await _circleManager?.create(
      mapbox.CircleAnnotationOptions(
        geometry: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
        circleRadius: 10.0,
        circleColor: 0xFF3654FF,
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 10)],
            ),
            child: Text(widget.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 205,
              child: widget.lat != null && widget.lng != null
                  ? mapbox.MapWidget(
                      key: const ValueKey('customer_location_map'),
                      onMapCreated: _onMapCreated,
                      cameraOptions: mapbox.CameraOptions(
                        center: mapbox.Point(
                          coordinates: mapbox.Position(widget.lng!, widget.lat!),
                        ),
                        zoom: 15.0,
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFCDD8F0), Color(0xFFB5D4E8)],
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_off_outlined, size: 32, color: Color(0xFF94A3B8)),
                            SizedBox(height: 8),
                            Text(
                              'Lokasi GPS belum diaktifkan',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.tracking});

  final OrderTrackingData tracking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT STATUS',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.6),
          ),
          const SizedBox(height: 18),
          ...tracking.statusSteps.map((step) => _StatusStepTile(step: step)),
        ],
      ),
    );
  }
}

class _StatusStepTile extends StatelessWidget {
  const _StatusStepTile({required this.step});

  final TrackingStatusStep step;

  @override
  Widget build(BuildContext context) {
    final activeColor = step.isCurrent ? const Color(0xFF4163FF) : const Color(0xFFE7EBF2);
    final iconColor = step.isCurrent || step.isComplete ? Colors.white : const Color(0xFF9CA5B6);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                child: Icon(
                  step.isCurrent || step.isComplete ? Icons.more_horiz_rounded : Icons.circle_outlined,
                  size: 16,
                  color: iconColor,
                ),
              ),
              Container(width: 2, height: 42, color: const Color(0xFFE6EAF1)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: step.isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: step.isCurrent ? Colors.black : const Color(0xFF9CA5B6),
                    ),
                  ),
                  if (step.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      style: TextStyle(
                        color: step.isCurrent ? const Color(0xFF60697A) : const Color(0xFFB1B8C6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityCodeCard extends StatelessWidget {
  const _SecurityCodeCard({required this.code, this.isPending = false});

  final String code;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          const Text(
            'KODE VERIFIKASI',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.6),
          ),
          const SizedBox(height: 14),
          if (isPending) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_top_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Kode akan muncul setelah teknisi mengkonfirmasi pesanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(code.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 36,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        code[index],
                        style: const TextStyle(
                          color: Color(0xFF3654FF),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            const Text(
              'Berikan kode ini kepada teknisi saat tiba di lokasi.',
              style: TextStyle(color: Color(0xFF737B8C)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TechnicianContactCard extends StatelessWidget {
  const _TechnicianContactCard({
    required this.name,
    required this.role,
    required this.partnerLabel,
    this.imageUrl,
    this.bookingDoc,
  });

  final String name;
  final String role;
  final String partnerLabel;
  final String? imageUrl;
  final BookingDocument? bookingDoc;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF94A3B8),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(role, style: const TextStyle(color: Color(0xFF727B8B), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(partnerLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
<<<<<<< HEAD
                  onPressed: bookingDoc == null
                      ? null
                      : () => Get.toNamed(
                            '/chat',
                            arguments: {
                              'chatId': bookingDoc!.bookingId,
                              'otherPartyName': bookingDoc!.technicianName,
                              'otherPartyPhotoUrl': bookingDoc!.technicianPhotoUrl,
                              'bookingDoc': bookingDoc,
                            },
                          ),
=======
                  onPressed: () => Get.toNamed(AppRoutes.chat),
>>>>>>> origin/main
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Message'),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.call_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Review Banner ──────────────────────────────────────────────────────────
class _ReviewBanner extends StatelessWidget {
  final BookingDocument booking;
  const _ReviewBanner({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE7FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Pekerjaan Selesai!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Bagaimana pengalamanmu? Berikan ulasan untuk teknisi.',
            style: TextStyle(color: Color(0xFF67728B), height: 1.4),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Get.toNamed(AppRoutes.review, arguments: booking),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('BERI ULASAN',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

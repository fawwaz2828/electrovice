import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:url_launcher/url_launcher.dart';

import '../../config/mapbox_config.dart';
import '../../config/routes.dart';
import '../../models/booking_document.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../utils/maps_launcher.dart';
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
          final booking = controller.activeBooking.value;

          // ── No active booking state ──────────────────────────
          if (booking == null) {
            // Masih loading (history stream belum selesai)
            if (controller.isLoadingHistory.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return _NoActiveOrderState(
              onGoToHistory: () =>
                  Get.toNamed(AppRoutes.orderHistory),
            );
          }

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
                  techLat: controller.technicianLat.value,
                  techLng: controller.technicianLng.value,
                ),
                const SizedBox(height: 14),
                _StatusCard(tracking: tracking),
                const SizedBox(height: 14),
                _SecurityCodeCard(
                  code: tracking.securityCode,
                  isPending: booking.status == BookingStatus.pending,
                ),
                const SizedBox(height: 14),
                _TechnicianContactCard(
                  name: tracking.technicianName,
                  role: tracking.technicianRole,
                  partnerLabel: tracking.partnerLabel,
                  imageUrl: tracking.technicianAvatarUrl,
                  bookingDoc: booking,
                ),
                // ── Cancel button (pending / confirmed only) ──
                if (booking.status == BookingStatus.pending ||
                    booking.status == BookingStatus.confirmed)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _CancelOrderButton(controller: controller),
                  ),
                // ── Pay Now banner (awaiting_payment) ─────────
                if (booking.status == BookingStatus.awaitingPayment)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _PayNowBanner(booking: booking),
                  ),
                // ── Review prompt saat done ────────────────────
                if (booking.status == BookingStatus.done &&
                    booking.customerRating == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _ReviewBanner(booking: booking),
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
  const _LiveMapCard({
    required this.title,
    this.lat,
    this.lng,
    this.techLat,
    this.techLng,
  });

  final String title;
  // Customer location
  final double? lat;
  final double? lng;
  // Technician live location
  final double? techLat;
  final double? techLng;

  @override
  State<_LiveMapCard> createState() => _LiveMapCardState();
}

class _LiveMapCardState extends State<_LiveMapCard> {
  mapbox.MapboxMap? _map;
  mapbox.CircleAnnotationManager? _customerCircleManager;
  mapbox.CircleAnnotationManager? _techCircleManager;
  mapbox.PolylineAnnotationManager? _polylineManager;

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    _map = map;
    _polylineManager = await map.annotations.createPolylineAnnotationManager();
    _customerCircleManager = await map.annotations.createCircleAnnotationManager();
    _techCircleManager = await map.annotations.createCircleAnnotationManager();
    await _updateAnnotations();
  }

  @override
  void didUpdateWidget(_LiveMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final coordsChanged = widget.lat != oldWidget.lat ||
        widget.lng != oldWidget.lng ||
        widget.techLat != oldWidget.techLat ||
        widget.techLng != oldWidget.techLng;
    if (coordsChanged) _updateAnnotations();
  }

  Future<void> _updateAnnotations() async {
    if (_map == null) return;

    // ── Customer marker (blue) ───────────────────────────────────
    await _customerCircleManager?.deleteAll();
    if (widget.lat != null && widget.lng != null) {
      await _customerCircleManager?.create(
        mapbox.CircleAnnotationOptions(
          geometry: mapbox.Point(
              coordinates: mapbox.Position(widget.lng!, widget.lat!)),
          circleRadius: 10.0,
          circleColor: 0xFF3654FF,
          circleStrokeWidth: 3.0,
          circleStrokeColor: 0xFFFFFFFF,
        ),
      );
    }

    // ── Technician marker (orange) ───────────────────────────────
    await _techCircleManager?.deleteAll();
    if (widget.techLat != null && widget.techLng != null) {
      await _techCircleManager?.create(
        mapbox.CircleAnnotationOptions(
          geometry: mapbox.Point(
              coordinates: mapbox.Position(widget.techLng!, widget.techLat!)),
          circleRadius: 11.0,
          circleColor: 0xFFF97316, // orange
          circleStrokeWidth: 3.0,
          circleStrokeColor: 0xFFFFFFFF,
        ),
      );
    }

    // ── Camera: fit both points or center on customer ────────────
    final hasBoth = widget.lat != null &&
        widget.lng != null &&
        widget.techLat != null &&
        widget.techLng != null;

    if (hasBoth) {
      // Fit camera to bounding box of both markers with padding
      final minLat = min(widget.lat!, widget.techLat!);
      final maxLat = max(widget.lat!, widget.techLat!);
      final minLng = min(widget.lng!, widget.techLng!);
      final maxLng = max(widget.lng!, widget.techLng!);
      // Midpoint + zoom level that covers the spread
      final midLat = (minLat + maxLat) / 2;
      final midLng = (minLng + maxLng) / 2;
      // Rough zoom based on distance
      final latSpan = (maxLat - minLat).abs();
      final lngSpan = (maxLng - minLng).abs();
      final span = max(latSpan, lngSpan);
      final zoom = span < 0.005 ? 15.0
          : span < 0.02 ? 14.0
          : span < 0.05 ? 13.0
          : span < 0.1 ? 12.0
          : 11.0;
      await _map!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(coordinates: mapbox.Position(midLng, midLat)),
          zoom: zoom,
        ),
        mapbox.MapAnimationOptions(duration: 800),
      );
      // Draw route between tech and customer
      _drawRoute();
    } else if (widget.lat != null && widget.lng != null) {
      await _map!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
              coordinates: mapbox.Position(widget.lng!, widget.lat!)),
          zoom: 15.0,
        ),
        mapbox.MapAnimationOptions(duration: 800),
      );
      // Clear any stale route
      await _polylineManager?.deleteAll();
    }
  }

  // ── Fetch Mapbox Directions route and draw polyline ────────────
  Future<void> _drawRoute() async {
    if (widget.techLat == null || widget.techLng == null ||
        widget.lat == null || widget.lng == null) return;

    try {
      final coords = await _fetchRoute(
        fromLat: widget.techLat!,
        fromLng: widget.techLng!,
        toLat: widget.lat!,
        toLng: widget.lng!,
      );
      if (coords == null || coords.isEmpty || _polylineManager == null) return;

      await _polylineManager!.deleteAll();
      await _polylineManager!.create(
        mapbox.PolylineAnnotationOptions(
          geometry: mapbox.LineString(
            coordinates: coords
                .map((c) => mapbox.Position(c[0], c[1]))
                .toList(),
          ),
          lineColor: 0xFF4163FF,
          lineWidth: 4.0,
        ),
      );
    } catch (e) {
      debugPrint('_drawRoute error: $e');
    }
  }

  /// Mapbox Directions API — driving route from [from] to [to].
  /// Returns list of [lng, lat] coordinate pairs.
  static Future<List<List<double>>?> _fetchRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '$fromLng,$fromLat;$toLng,$toLat'
        '?geometries=geojson&overview=simplified'
        '&access_token=$mapboxPublicToken',
      );
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final body = await response.transform(utf8.decoder).join();
      client.close();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final routes = json['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;
      final rawCoords =
          (routes[0]['geometry']['coordinates'] as List).cast<List>();
      return rawCoords
          .map((c) => [
                (c[0] as num).toDouble(),
                (c[1] as num).toDouble(),
              ])
          .toList();
    } catch (e) {
      debugPrint('_fetchRoute error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomer = widget.lat != null && widget.lng != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Color(0x11000000), blurRadius: 10)
                    ],
                  ),
                  child: Text(widget.title,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
              // Legend: customer dot + tech dot (only when tech is streaming)
              if (widget.techLat != null) ...[
                const SizedBox(width: 8),
                _MapLegendDot(color: const Color(0xFF3654FF), label: 'You'),
                const SizedBox(width: 8),
                _MapLegendDot(
                    color: const Color(0xFFF97316), label: 'Technician'),
              ],
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 205,
              child: hasCustomer
                  ? mapbox.MapWidget(
                      key: const ValueKey('tracking_map'),
                      onMapCreated: _onMapCreated,
                      cameraOptions: mapbox.CameraOptions(
                        center: mapbox.Point(
                          coordinates:
                              mapbox.Position(widget.lng!, widget.lat!),
                        ),
                        zoom: 15.0,
                      ),
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
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
                            Icon(Icons.location_off_outlined,
                                size: 32, color: Color(0xFF94A3B8)),
                            SizedBox(height: 8),
                            Text(
                              'GPS location not enabled',
                              style: TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 12),
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

class _MapLegendDot extends StatelessWidget {
  const _MapLegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
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
            'VERIFICATION CODE',
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
                      'Code will appear after the technician confirms the order',
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
              'Show this code to the technician upon arrival.',
              style: TextStyle(color: Color(0xFF737B8C)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TechnicianContactCard extends StatefulWidget {
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
  State<_TechnicianContactCard> createState() => _TechnicianContactCardState();
}

class _TechnicianContactCardState extends State<_TechnicianContactCard> {
  bool _isCalling = false;

  Future<void> _callTechnician() async {
    final techId = widget.bookingDoc?.technicianId;
    if (techId == null || techId.isEmpty) return;
    setState(() => _isCalling = true);
    try {
      final user = await AuthService().getUserModel(techId);
      final phone = (user?.phone ?? '').trim();
      if (phone.isEmpty) {
        Get.snackbar('Not available', 'Technician phone number is not registered',
            snackPosition: SnackPosition.TOP);
        return;
      }
      await launchUrl(Uri(scheme: 'tel', path: phone));
    } catch (e) {
      Get.snackbar('Failed', 'Unable to open phone app',
          snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) setState(() => _isCalling = false);
    }
  }

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
                    Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(widget.role, style: const TextStyle(color: Color(0xFF727B8B), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(widget.partnerLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
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
                  onPressed: widget.bookingDoc == null
                      ? null
                      : () => Get.toNamed(
                            '/chat',
                            arguments: {
                              'chatId': widget.bookingDoc!.bookingId,
                              'otherPartyName': widget.bookingDoc!.technicianName,
                              'otherPartyPhotoUrl': widget.bookingDoc!.technicianPhotoUrl,
                              'bookingDoc': widget.bookingDoc,
                            },
                          ),
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
              // ── Call Technician ──────────────────────────────────
              GestureDetector(
                onTap: _isCalling ? null : _callTechnician,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isCalling
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.phone_outlined, color: Color(0xFF4163FF)),
                ),
              ),
              const SizedBox(width: 10),
              // ── Navigate ─────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  final lat = widget.bookingDoc?.latitude;
                  final lng = widget.bookingDoc?.longitude;
                  if (lat != null && lng != null) {
                    MapsLauncher.navigateTo(lat: lat, lng: lng);
                  } else {
                    Get.snackbar(
                      'Location not available',
                      'Customer has not enabled GPS',
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.navigation_rounded,
                      color: Color(0xFF4163FF)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pay Now Banner ────────────────────────────────────────────────────────
class _PayNowBanner extends StatelessWidget {
  final BookingDocument booking;
  const _PayNowBanner({required this.booking});

  String _rp(int v) {
    if (v == 0) return 'Rp 0';
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final total = booking.finalTotalAmount ?? booking.estimatedPrice;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFCBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Color(0xFF4163FF), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Payment Ready',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Technician has completed the diagnosis. Total amount due: ${_rp(total)}',
            style: const TextStyle(color: Color(0xFF4B5563), height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Get.toNamed(AppRoutes.payService),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4163FF),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('PAY NOW', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ── Cancel Order Button ────────────────────────────────────────────────────
class _CancelOrderButton extends StatelessWidget {
  final BookingController controller;
  const _CancelOrderButton({required this.controller});

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Order?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Cancelled orders cannot be reversed. Are you sure you want to cancel?',
          style: TextStyle(color: Color(0xFF64748B), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'No',
              style: TextStyle(
                  color: Color(0xFF64748B), fontWeight: FontWeight.w700),
            ),
          ),
          Obx(() => TextButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.cancelBooking(),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFFDC2626)),
                      )
                    : const Text(
                        'Yes, Cancel',
                        style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w800),
                      ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showConfirmDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 8),
            Text(
              'Cancel Order',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── No Active Order State ─────────────────────────────────────────────────
class _NoActiveOrderState extends StatelessWidget {
  final VoidCallback onGoToHistory;
  const _NoActiveOrderState({required this.onGoToHistory});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Active Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have no ongoing orders. Start a booking to track your service status.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onGoToHistory,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('View History',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.technicianList),
              child: const Text(
                'Find Technician →',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0061FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
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
                'Job Complete!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'How was your experience? Leave a review for the technician.',
            style: TextStyle(color: Color(0xFF67728B), height: 1.4),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Get.toNamed(AppRoutes.review, arguments: booking),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('WRITE REVIEW',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

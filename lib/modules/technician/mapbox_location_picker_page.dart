import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxLocationPickerPage extends StatefulWidget {
  const MapboxLocationPickerPage({super.key});

  @override
  State<MapboxLocationPickerPage> createState() =>
      _MapboxLocationPickerPageState();
}

class _MapboxLocationPickerPageState
    extends State<MapboxLocationPickerPage> {
  MapboxMap? _mapboxMap;
  Point? _selectedPoint;
  bool _isConfirming = false;

  // Koordinat default — Makassar
  // Ganti sesuai kota kamu
  static const double _defaultLat = -5.1477;
  static const double _defaultLng = 119.4327;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Mapbox Map ──────────────────────────────────────────
          MapWidget(
            key: const ValueKey('mapbox_picker'),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(_defaultLng, _defaultLat),
              ),
              zoom: 14.0,
            ),
            onMapCreated: _onMapCreated,
            onTapListener: _onMapTap,
          ),

          // ── Header ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Tap lokasi workshop di peta',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Center Pin ─────────────────────────────────────────
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF3254FF),
                  size: 48,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                SizedBox(height: 24),
              ],
            ),
          ),

          // ── Bottom Confirm Button ───────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedPoint != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '📍 ${_selectedPoint!.coordinates.lat.toStringAsFixed(6)}, '
                          '${_selectedPoint!.coordinates.lng.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedPoint == null
                            ? null
                            : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3254FF),
                          disabledBackgroundColor:
                              const Color(0xFF94A3B8),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isConfirming
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Konfirmasi Lokasi Ini',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;

    // Aktifkan location puck (titik biru posisi user)
    _mapboxMap?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );
  }

  void _onMapTap(MapContentGestureContext context) {
    setState(() {
      _selectedPoint = context.point;
    });
  }

  void _confirmLocation() {
    if (_selectedPoint == null) return;

    final double lat = _selectedPoint!.coordinates.lat.toDouble();
    final double lng = _selectedPoint!.coordinates.lng.toDouble();

    // Kembalikan koordinat ke halaman sebelumnya
    Get.back(result: {'lat': lat, 'lng': lng});
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart' hide Position;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxLocationPickerPage extends StatefulWidget {
  const MapboxLocationPickerPage({super.key});

  @override
  State<MapboxLocationPickerPage> createState() =>
      _MapboxLocationPickerPageState();
}

class _MapboxLocationPickerPageState extends State<MapboxLocationPickerPage> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
  PointAnnotation? _currentAnnotation;
  Point? _selectedPoint;

  // Fallback koordinat — Makassar
  static const double _defaultLat = -5.1477;
  static const double _defaultLng = 119.4327;

  @override
  void initState() {
    super.initState();
    _goToUserLocation();
  }

  // Coba dapat lokasi user sebelum map siap, simpan untuk dipakai di _onMapCreated
  double? _pendingLat;
  double? _pendingLng;

  Future<void> _goToUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _pendingLat = position.latitude;
      _pendingLng = position.longitude;

      // Jika map sudah siap, langsung fly
      if (_mapboxMap != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 1200),
        );
      }
    } catch (_) {
      // Gagal dapat lokasi — tetap pakai default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Mapbox Map ──────────────────────────────────────────
          SizedBox.expand(
            child: MapWidget(
              key: const ValueKey('mapbox_picker'),
              styleUri: MapboxStyles.MAPBOX_STREETS,
              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(_defaultLng, _defaultLat),
                ),
                zoom: 13.0,
              ),
              onMapCreated: _onMapCreated,
              onTapListener: _onMapTap,
            ),
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
                              color: Colors.black.withValues(alpha: 0.1),
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
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          _selectedPoint == null
                              ? 'Tap lokasi workshop di peta'
                              : '${_selectedPoint!.coordinates.lat.toStringAsFixed(6)}, '
                                  '${_selectedPoint!.coordinates.lng.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedPoint == null
                                ? const Color(0xFF64748B)
                                : const Color(0xFF3254FF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Tombol lokasi saya (kanan bawah, di atas confirm button) ──
          Positioned(
            bottom: 120,
            right: 20,
            child: GestureDetector(
              onTap: _goToUserLocation,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF3254FF),
                  size: 22,
                ),
              ),
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedPoint == null ? null : _confirmLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3254FF),
                      disabledBackgroundColor: const Color(0xFF94A3B8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _selectedPoint == null
                          ? 'Tap di peta untuk memilih lokasi'
                          : 'Konfirmasi Lokasi Ini',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Aktifkan location puck (titik biru posisi user)
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    // Buat annotation manager untuk marker tap
    _annotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    // Kalau lokasi user sudah ready sebelum map siap, fly ke sana sekarang
    if (_pendingLat != null && _pendingLng != null) {
      await mapboxMap.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(_pendingLng!, _pendingLat!),
          ),
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 1200),
      );
    }
  }

  Future<void> _onMapTap(MapContentGestureContext context) async {
    final tappedPoint = context.point;

    setState(() {
      _selectedPoint = tappedPoint;
    });

    if (_annotationManager == null) return;

    // Hapus marker lama kalau ada
    if (_currentAnnotation != null) {
      await _annotationManager!.delete(_currentAnnotation!);
      _currentAnnotation = null;
    }

    // Buat marker baru di titik yang di-tap
    _currentAnnotation = await _annotationManager!.create(
      PointAnnotationOptions(
        geometry: tappedPoint,
        iconSize: 1.5,
        iconImage: 'marker-default',  // built-in Mapbox marker
        textField: 'Workshop',
        textOffset: [0.0, -2.5],
        textColor: 0xFF3254FF,
        textSize: 12.0,
        textHaloColor: 0xFFFFFFFF,
        textHaloWidth: 1.5,
      ),
    );
  }

  void _confirmLocation() {
    if (_selectedPoint == null) return;

    final double lat = _selectedPoint!.coordinates.lat.toDouble();
    final double lng = _selectedPoint!.coordinates.lng.toDouble();

    Get.back(result: {'lat': lat, 'lng': lng});
  }
}

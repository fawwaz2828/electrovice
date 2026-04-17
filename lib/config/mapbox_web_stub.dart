// Stub untuk menggantikan mapbox_maps_flutter di platform web
// Berisi class/typedef kosong agar kode compile tanpa error di web

import 'package:flutter/material.dart';

class MapboxOptions {
  static void setAccessToken(String token) {}
}

class GesturesManager {
  Future<void> updateSettings(GesturesSettings settings) async {}
}

class LocationManager {
  Future<void> updateSettings(LocationComponentSettings settings) async {}
}

class CircleAnnotation {}

class CircleAnnotationOptions {
  CircleAnnotationOptions({
    Point? geometry,
    double? circleRadius,
    int? circleColor,
    double? circleStrokeWidth,
    int? circleStrokeColor,
  });
}

class CircleAnnotationManager {
  Future<void> delete(CircleAnnotation annotation) async {}
  Future<CircleAnnotation> create(CircleAnnotationOptions options) async =>
      CircleAnnotation();
}

class AnnotationsManager {
  Future<PointAnnotationManager> createPointAnnotationManager() async =>
      PointAnnotationManager();
  Future<CircleAnnotationManager> createCircleAnnotationManager() async =>
      CircleAnnotationManager();
}

class MapboxMap {
  GesturesManager get gestures => GesturesManager();
  LocationManager get location => LocationManager();
  AnnotationsManager get annotations => AnnotationsManager();
  Future<void> flyTo(CameraOptions options, [MapAnimationOptions? mapAnimationOptions]) async {}
}

class PointAnnotationManager {
  Future<void> delete(PointAnnotation annotation) async {}
  Future<PointAnnotation> create(PointAnnotationOptions options) async =>
      PointAnnotation();
}

class PointAnnotation {}
class MapAnimationOptions {
  MapAnimationOptions({int? duration});
}
class CameraOptions {
  CameraOptions({Point? center, double? zoom});
}
class Point {
  final Position coordinates;
  Point({required this.coordinates});
}
class Position {
  final double lng;
  final double lat;
  Position(this.lng, this.lat);
}
class LocationComponentSettings {
  LocationComponentSettings({bool? enabled, bool? pulsingEnabled});
}
class PointAnnotationOptions {
  PointAnnotationOptions({
    Point? geometry,
    double? iconSize,
    String? iconImage,
    String? textField,
    List<double>? textOffset,
    int? textColor,
    double? textSize,
    int? textHaloColor,
    double? textHaloWidth,
  });
}
class MapContentGestureContext {
  Point get point => Point(coordinates: Position(0, 0));
}

class GesturesSettings {
  GesturesSettings({
    bool? scrollEnabled,
    bool? rotateEnabled,
    bool? pitchEnabled,
    bool? pinchToZoomEnabled,
    bool? doubleTapToZoomInEnabled,
    bool? doubleTouchToZoomOutEnabled,
    bool? quickZoomEnabled,
    bool? simultaneousRotateAndPinchToZoomEnabled,
    bool? pinchScrollEnabled,
  });
}

abstract class MapboxStyles {
  static const String MAPBOX_STREETS = '';
  static const String OUTDOORS = '';
  static const String SATELLITE = '';
  static const String SATELLITE_STREETS = '';
  static const String LIGHT = '';
  static const String DARK = '';
}

class MapWidget extends StatelessWidget {
  const MapWidget({
    super.key,
    String? styleUri,
    CameraOptions? cameraOptions,
    Function(MapboxMap)? onMapCreated,
    Function(MapContentGestureContext)? onTapListener,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text(
              'Peta tidak tersedia di web',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gunakan aplikasi mobile untuk memilih lokasi',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

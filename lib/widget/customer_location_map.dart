import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

/// Widget Mapbox yang menampilkan pin lokasi customer.
/// Digunakan di job_detail_page dan verification_page.
class CustomerLocationMap extends StatefulWidget {
  final double lat;
  final double lng;

  const CustomerLocationMap({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  State<CustomerLocationMap> createState() => _CustomerLocationMapState();
}

class _CustomerLocationMapState extends State<CustomerLocationMap> {
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
      key: ValueKey('cust_map_${widget.lat}_${widget.lng}'),
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

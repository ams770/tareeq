import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteInfo {
  final List<LatLng> polylinePoints;
  final String distanceText;
  final String durationText;
  final LatLngBounds bounds;

  const RouteInfo({
    required this.polylinePoints,
    required this.distanceText,
    required this.durationText,
    required this.bounds,
  });
}

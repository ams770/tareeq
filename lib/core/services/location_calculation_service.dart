import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Interface defining the contract for executing geodesic/geometric coordinate calculations offline.
abstract class LocationCalculationService {
  /// Calculates the distance in meters between two [LatLng] coordinates.
  double calculateDistance(LatLng start, LatLng end);

  /// Calculates the mathematical bearing/heading in degrees between two [LatLng] coordinates.
  double calculateBearing(LatLng start, LatLng end);
}

/// Concrete implementation of the [LocationCalculationService] interface.
class LocationCalculationServiceImpl implements LocationCalculationService {
  @override
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  @override
  double calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * pi / 180.0;
    final double lon1 = start.longitude * pi / 180.0;
    final double lat2 = end.latitude * pi / 180.0;
    final double lon2 = end.longitude * pi / 180.0;

    final double dLon = lon2 - lon1;

    final double y = sin(dLon) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    final double radians = atan2(y, x);
    final double degrees = radians * 180.0 / pi;
    return (degrees + 360.0) % 360.0;
  }
}

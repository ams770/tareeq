import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  final LatLng position;
  final double heading;

  const UserLocation({
    required this.position,
    required this.heading,
  });
}

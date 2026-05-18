import 'package:geolocator/geolocator.dart';


class LocationService {
  /// Check and request location permission.
  /// Returns true if granted (while in use or always), throws detailed Exception otherwise.
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const FormatException('Location services (GPS) are disabled on your device. Please enable location services in your system settings to continue.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const FormatException('Location permission is denied. To use this application, you must grant location permissions.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const FormatException('Location permission is permanently denied. Please enable location permissions manually in your device settings.');
    }

    return true;
  }

  /// Get the user's current GPS location coordinates.
  /// Throws an exception or returns null if permissions are denied or GPS is disabled.
  Future<Position> getCurrentLocation() async {
    await checkAndRequestPermission();

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  /// Exposes a stream of user's real-time position changes.
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // Emits every 2 meters for real-time smoothness
      ),
    );
  }
}

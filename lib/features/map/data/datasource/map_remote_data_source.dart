import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/google_maps_service.dart';
import '../../../../core/services/directions_service.dart';

class MapRemoteDataSource {
  final LocationService _locationService;
  final GoogleMapsService _googleMapsService;
  final DirectionsService _directionsService;

  MapRemoteDataSource({
    required LocationService locationService,
    required GoogleMapsService googleMapsService,
    required DirectionsService directionsService,
  })  : _locationService = locationService,
        _googleMapsService = googleMapsService,
        _directionsService = directionsService;

  /// Fetch suggestions for search autocomplete
  Future<List<dynamic>> searchPlaces(String query, String sessionToken) {
    return _googleMapsService.getAutocompletePredictions(query, sessionToken);
  }

  /// Get geometry coordinates for selected prediction
  Future<Map<String, dynamic>> getPlaceGeometry(String placeId) {
    return _googleMapsService.getPlaceGeometry(placeId);
  }

  /// Get route between origin and destination coordinates
  Future<Map<String, dynamic>> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return _directionsService.getDirections(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
  }

  /// Get current GPS location
  Future<Position> getCurrentLocation() {
    return _locationService.getCurrentLocation();
  }

  /// Get real-time GPS location stream
  Stream<Position> getLocationStream() {
    return _locationService.getLocationStream();
  }
}

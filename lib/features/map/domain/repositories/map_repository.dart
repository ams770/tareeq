import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/place_prediction.dart';
import '../entities/route_info.dart';
import '../entities/user_location.dart';

abstract class MapRepository {
  /// Searches for places matching [query].
  Future<List<PlacePrediction>> searchPlaces(String query, String sessionToken);

  /// Retrieves latitude and longitude coordinates for a selected [placeId].
  Future<LatLng> getPlaceDetails(String placeId);

  /// Retrieves route info, bounds and decoded polyline points between origin and destination.
  Future<RouteInfo> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });

  /// Retrieves current user location.
  Future<LatLng> getCurrentLocation();

  /// Subscribes to real-time user location coordinates.
  Stream<UserLocation> getLocationStream();
}

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tareeq/core/constants/app_strings.dart';
import '../../domain/entities/place_prediction.dart';
import '../../domain/entities/route_info.dart';
import '../../domain/entities/user_location.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasource/map_remote_data_source.dart';
import '../models/place_prediction_model.dart';
import '../models/route_info_model.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource _remoteDataSource;

  MapRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PlacePrediction>> searchPlaces(String query, String sessionToken) async {
    try {
      final rawPredictions = await _remoteDataSource.searchPlaces(query, sessionToken);
      return rawPredictions
          .map((json) => PlacePredictionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('${AppStrings.errorFailedSearchPlaces}$e');
    }
  }

  @override
  Future<LatLng> getPlaceDetails(String placeId) async {
    try {
      final geometry = await _remoteDataSource.getPlaceGeometry(placeId);
      return LatLng(
        geometry[AppStrings.keyLat] as double,
        geometry[AppStrings.keyLng] as double,
      );
    } catch (e) {
      throw Exception('${AppStrings.errorFailedFetchPlaceDetails}$e');
    }
  }

  @override
  Future<RouteInfo> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final rawDirections = await _remoteDataSource.getDirections(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
      return RouteInfoModel.fromJson(rawDirections);
    } catch (e) {
      throw Exception('${AppStrings.errorFailedFetchRouteDirections}$e');
    }
  }

  @override
  Future<LatLng> getCurrentLocation() async {
    try {
      final position = await _remoteDataSource.getCurrentLocation();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('${AppStrings.errorFailedGetCurrentLocation}$e');
    }
  }

  @override
  Stream<UserLocation> getLocationStream() {
    return _remoteDataSource.getLocationStream().map((pos) {
      return UserLocation(
        position: LatLng(pos.latitude, pos.longitude),
        heading: pos.heading,
      );
    });
  }
}

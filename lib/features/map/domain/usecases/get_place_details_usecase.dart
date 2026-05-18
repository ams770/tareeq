import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repositories/map_repository.dart';

class GetPlaceDetailsUseCase {
  final MapRepository _repository;

  GetPlaceDetailsUseCase(this._repository);

  Future<LatLng> call(String placeId) {
    return _repository.getPlaceDetails(placeId);
  }
}

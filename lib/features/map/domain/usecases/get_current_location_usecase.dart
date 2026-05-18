import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repositories/map_repository.dart';

class GetCurrentLocationUseCase {
  final MapRepository _repository;

  GetCurrentLocationUseCase(this._repository);

  Future<LatLng> call() {
    return _repository.getCurrentLocation();
  }
}

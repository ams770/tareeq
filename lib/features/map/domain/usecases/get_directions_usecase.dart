import '../entities/route_info.dart';
import '../repositories/map_repository.dart';

class GetDirectionsUseCase {
  final MapRepository _repository;

  GetDirectionsUseCase(this._repository);

  Future<RouteInfo> call({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return _repository.getRoute(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
  }
}

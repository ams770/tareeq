import '../entities/place_prediction.dart';
import '../repositories/map_repository.dart';

class SearchPlacesUseCase {
  final MapRepository _repository;

  SearchPlacesUseCase(this._repository);

  Future<List<PlacePrediction>> call(String query, String sessionToken) {
    return _repository.searchPlaces(query, sessionToken);
  }
}

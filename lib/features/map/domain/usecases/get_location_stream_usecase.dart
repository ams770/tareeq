import '../entities/user_location.dart';
import '../repositories/map_repository.dart';

class GetLocationStreamUseCase {
  final MapRepository _repository;

  GetLocationStreamUseCase(this._repository);

  Stream<UserLocation> call() {
    return _repository.getLocationStream();
  }
}

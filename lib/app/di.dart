import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../core/services/directions_service.dart';
import '../core/services/google_maps_service.dart';
import '../core/services/location_service.dart';
import '../core/services/location_calculation_service.dart';
import '../core/services/marker_service.dart';
import '../core/services/polyline_service.dart';
import '../features/map/cubit/map_cubit.dart';
import '../features/map/data/datasource/map_remote_data_source.dart';
import '../features/map/data/repositories/map_repository_impl.dart';
import '../features/map/domain/repositories/map_repository.dart';
import '../features/map/domain/usecases/get_current_location_usecase.dart';
import '../features/map/domain/usecases/get_directions_usecase.dart';
import '../features/map/domain/usecases/get_location_stream_usecase.dart';
import '../features/map/domain/usecases/get_place_details_usecase.dart';
import '../features/map/domain/usecases/search_places_usecase.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // 1. External dependencies
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // 2. Core services
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<GoogleMapsService>(() => GoogleMapsService(client: sl()));
  sl.registerLazySingleton<DirectionsService>(() => DirectionsService(client: sl()));
  sl.registerLazySingleton<PolylineService>(() => PolylineServiceImpl());
  sl.registerLazySingleton<LocationCalculationService>(
    () => LocationCalculationServiceImpl(),
  );
  sl.registerLazySingleton<MarkerService>(() => MarkerServiceImpl());

  // 3. Features - Map Layer
  // Data Source
  sl.registerLazySingleton<MapRemoteDataSource>(
    () => MapRemoteDataSource(
      locationService: sl(),
      googleMapsService: sl(),
      directionsService: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton<GetCurrentLocationUseCase>(() => GetCurrentLocationUseCase(sl()));
  sl.registerLazySingleton<SearchPlacesUseCase>(() => SearchPlacesUseCase(sl()));
  sl.registerLazySingleton<GetPlaceDetailsUseCase>(() => GetPlaceDetailsUseCase(sl()));
  sl.registerLazySingleton<GetDirectionsUseCase>(() => GetDirectionsUseCase(sl()));
  sl.registerLazySingleton<GetLocationStreamUseCase>(() => GetLocationStreamUseCase(sl()));

  // Cubit
  sl.registerFactory<MapCubit>(
    () => MapCubit(
      getCurrentLocationUseCase: sl(),
      searchPlacesUseCase: sl(),
      getPlaceDetailsUseCase: sl(),
      getDirectionsUseCase: sl(),
      getLocationStreamUseCase: sl(),
      polylineService: sl(),
      locationCalculationService: sl(),
      markerService: sl(),
    ),
  );
}

import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../domain/entities/place_prediction.dart';
import '../domain/entities/user_location.dart';
import '../domain/usecases/get_current_location_usecase.dart';
import '../domain/usecases/get_directions_usecase.dart';
import '../domain/usecases/get_location_stream_usecase.dart';
import '../domain/usecases/get_place_details_usecase.dart';
import '../domain/usecases/search_places_usecase.dart';
import '../../../core/services/polyline_service.dart';
import '../../../core/services/location_calculation_service.dart';
import '../../../core/services/marker_service.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final SearchPlacesUseCase _searchPlacesUseCase;
  final GetPlaceDetailsUseCase _getPlaceDetailsUseCase;
  final GetDirectionsUseCase _getDirectionsUseCase;
  final GetLocationStreamUseCase _getLocationStreamUseCase;
  final PolylineService _polylineService;
  final LocationCalculationService _locationCalculationService;
  final MarkerService _markerService;

  GoogleMapController? mapController;
  String _sessionToken = AppStrings.empty;
  StreamSubscription<UserLocation>? _locationSubscription;
  bool _isFirstLocationEmit = true;
  double _lastHeading = AppSizes.defaultHeading;

  MapCubit({
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
    required SearchPlacesUseCase searchPlacesUseCase,
    required GetPlaceDetailsUseCase getPlaceDetailsUseCase,
    required GetDirectionsUseCase getDirectionsUseCase,
    required GetLocationStreamUseCase getLocationStreamUseCase,
    required PolylineService polylineService,
    required LocationCalculationService locationCalculationService,
    required MarkerService markerService,
  }) : _getCurrentLocationUseCase = getCurrentLocationUseCase,
       _searchPlacesUseCase = searchPlacesUseCase,
       _getPlaceDetailsUseCase = getPlaceDetailsUseCase,
       _getDirectionsUseCase = getDirectionsUseCase,
       _getLocationStreamUseCase = getLocationStreamUseCase,
       _polylineService = polylineService,
       _locationCalculationService = locationCalculationService,
       _markerService = markerService,
       super(const MapInitial()) {
    _refreshSessionToken();
  }

  /// Refreshes the Places session token for optimized billing API grouping.
  void _refreshSessionToken() {
    final random = Random();
    final parts = List.generate(
      4,
      (_) => random.nextInt(1000000).toString().padLeft(6, '0'),
    );
    _sessionToken =
        '${DateTime.now().millisecondsSinceEpoch}${AppStrings.underscore}${parts.join(AppStrings.empty)}';
  }

  /// Initializes map by requesting permissions and subscribing to real-time location stream.
  Future<void> initializeMap() async {
    emit(const MapLoading(message: AppStrings.locatingUser));

    // Reset flags
    _isFirstLocationEmit = true;

    // Cancel existing subscription if any
    await _locationSubscription?.cancel();

    try {
      // 1. Fetch current GPS position. This will check and prompt for permission if not granted.
      final initialPosition = await _getCurrentLocationUseCase();

      // 2. Pre-generate the user location marker to avoid flashing empty map
      final currentMarker = await _markerService.generateMarker(
        type: MapMarkerType.current,
        position: initialPosition,
        heading: _lastHeading,
      );

      emit(
        MapLoaded(
          currentLocation: initialPosition,
          markers: {currentMarker},
        ),
      );

      // 3. Smoothly center map viewport on user
      _animateToLocation(initialPosition, zoom: AppSizes.defaultUserZoom);
      _isFirstLocationEmit = false; // Already handled first transition
    } catch (e) {
      String errMsg = e.toString();
      if (errMsg.contains('Exception:')) {
        errMsg = errMsg.replaceAll('Exception:', '').trim();
      }
      if (errMsg.contains('FormatException:')) {
        errMsg = errMsg.replaceAll('FormatException:', '').trim();
      }
      emit(MapError(errMsg));
      return;
    }

    // Start listening to user's real-time coordinate and direction stream
    _locationSubscription = _getLocationStreamUseCase().listen(
      (userLocation) async {
        await _onLocationUpdated(userLocation);
      },
      onError: (e) {
        String errMsg = e.toString();
        if (errMsg.contains('Exception:')) {
          errMsg = errMsg.replaceAll('Exception:', '').trim();
        }
        if (errMsg.contains('FormatException:')) {
          errMsg = errMsg.replaceAll('FormatException:', '').trim();
        }
        emit(MapError(errMsg));
      },
    );
  }

  /// Internal handler called every time user's GPS coordinates or heading changes.
  Future<void> _onLocationUpdated(UserLocation userLocation) async {
    final currentState = state;
    double heading = userLocation.heading;

    if (currentState is MapLoaded && currentState.currentLocation != null) {
      final double distance = _locationCalculationService.calculateDistance(
        currentState.currentLocation!,
        userLocation.position,
      );
      // Only recalculate heading if user moved significantly to avoid sensor jitter
      if (distance > AppSizes.sensorJitterDistanceThreshold) {
        heading = _locationCalculationService.calculateBearing(
          currentState.currentLocation!,
          userLocation.position,
        );
      } else {
        heading = _lastHeading;
      }
    }
    _lastHeading = heading;

    // 1. Generate premium circular direction marker using MarkerService
    final currentMarker = await _markerService.generateMarker(
      type: MapMarkerType.current,
      position: userLocation.position,
      heading: heading,
    );

    if (currentState is MapLoaded) {
      // Retain destination pin, only replace the current user marker
      final Set<Marker> updatedMarkers = Set.from(currentState.markers)
        ..removeWhere((m) => m.markerId.value == AppStrings.markerIdCurrent)
        ..add(currentMarker);

      // Check if we are actively routing to a destination!
      if (currentState.destinationLocation != null) {
        // Calculate dynamic real-time distance in meters between user location and destination
        final double distanceToDestination = _locationCalculationService
            .calculateDistance(
              userLocation.position,
              currentState.destinationLocation!,
            );

        if (distanceToDestination <= AppSizes.arrivalThresholdMeters) {
          // USER ARRIVED! Remove polyline/route info, retain the pin, and emit arrival alert
          emit(
            currentState.copyWith(
              currentLocation: userLocation.position,
              markers: updatedMarkers,
              clearDestination: true,
              clearRouteInfo: true,
              polylines: {},
              arrivalMessage: AppStrings.arrivalMessageText,
            ),
          );

          // Return camera to initial values on arrival
          _animateToLocation(userLocation.position, zoom: AppSizes.defaultUserZoom);
        } else {
          // Not arrived yet: recalculate routing polyline dynamically
          try {
            final route = await _getDirectionsUseCase(
              originLat: userLocation.position.latitude,
              originLng: userLocation.position.longitude,
              destLat: currentState.destinationLocation!.latitude,
              destLng: currentState.destinationLocation!.longitude,
            );

            final routePolyline = _polylineService.generateRoutePolyline(
              route.polylinePoints,
            );

            emit(
              currentState.copyWith(
                currentLocation: userLocation.position,
                markers: updatedMarkers,
                routeInfo: route,
                polylines: {routePolyline},
              ),
            );
          } catch (e) {
            // Degrade gracefully: update location marker even if HTTP recalculation fails
            emit(
              currentState.copyWith(
                currentLocation: userLocation.position,
                markers: updatedMarkers,
              ),
            );
          }
        }
      } else {
        // Not routing, just update marker coordinates
        emit(
          currentState.copyWith(
            currentLocation: userLocation.position,
            markers: updatedMarkers,
          ),
        );
      }
    } else {
      // Transition from Loading / Initial to Loaded
      emit(
        MapLoaded(
          currentLocation: userLocation.position,
          markers: {currentMarker},
        ),
      );
    }

    // 2. Center camera automatically:
    if (_isFirstLocationEmit) {
      _isFirstLocationEmit = false;
      _animateToLocation(userLocation.position, zoom: AppSizes.defaultUserZoom);
    } else if (currentState is MapLoaded &&
        currentState.destinationLocation != null &&
        !currentState.isAutoCenteringDisabled) {
      // Keep centering camera on user in 3D perspective during navigation
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: userLocation.position,
            zoom: AppSizes.navigationZoom,
            tilt: AppSizes.navigationTilt,
            bearing: heading,
          ),
        ),
      );
    }
  }

  /// Searches for places matching [query] with direct HTTP API requests.
  Future<void> search(String query) async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    if (query.trim().isEmpty) {
      emit(currentState.copyWith(predictions: [], isSearching: false));
      return;
    }

    emit(currentState.copyWith(isSearching: true));

    try {
      final results = await _searchPlacesUseCase(query, _sessionToken);
      emit(currentState.copyWith(predictions: results, isSearching: false));
    } catch (e) {
      emit(currentState.copyWith(isSearching: false, predictions: []));
    }
  }

  /// Selects a prediction autocomplete item, fetches coordinates, calculates routing, and draws polylines.
  Future<void> selectPrediction(PlacePrediction prediction) async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    emit(currentState.copyWith(isRouting: true, predictions: []));

    try {
      // 1. Get destination coordinates
      final destLatLng = await _getPlaceDetailsUseCase(prediction.placeId);

      // 2. Ensure current location is active
      LatLng? originLatLng = currentState.currentLocation;
      originLatLng ??= await _getCurrentLocationUseCase();

      // 3. Get routing directions
      final route = await _getDirectionsUseCase(
        originLat: originLatLng.latitude,
        originLng: originLatLng.longitude,
        destLat: destLatLng.latitude,
        destLng: destLatLng.longitude,
      );

      // 4. Retrieve/generate dynamic user circular marker and destination marker
      final currentMarker = await _markerService.generateMarker(
        type: MapMarkerType.current,
        position: originLatLng,
        heading: _lastHeading,
      );

      final destMarker = await _markerService.generateMarker(
        type: MapMarkerType.destination,
        position: destLatLng,
        title: prediction.mainText,
        snippet: prediction.secondaryText,
      );

      // 5. Create path polyline with custom premium colors
      final routePolyline = _polylineService.generateRoutePolyline(
        route.polylinePoints,
      );

      // 6. Emit new loaded state
      emit(
        currentState.copyWith(
          currentLocation: originLatLng,
          destinationLocation: destLatLng,
          routeInfo: route,
          markers: {currentMarker, destMarker},
          polylines: {routePolyline},
          isRouting: false,
        ),
      );

      // 7. Refresh token for next session
      _refreshSessionToken();

      // 8. Focus camera on the user in 3D navigation perspective immediately
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: originLatLng,
            zoom: AppSizes.navigationZoom,
            tilt: AppSizes.navigationTilt,
            bearing: _lastHeading,
          ),
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isRouting: false));
      rethrow;
    }
  }

  /// Starts navigation routing directly to custom coordinates (e.g. from a map long-press gesture).
  Future<void> selectLatLngDestination(LatLng destLatLng) async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    emit(currentState.copyWith(isRouting: true, predictions: []));

    try {
      // 1. Ensure current location is active
      LatLng? originLatLng = currentState.currentLocation;
      originLatLng ??= await _getCurrentLocationUseCase();

      // 2. Get routing directions
      final route = await _getDirectionsUseCase(
        originLat: originLatLng.latitude,
        originLng: originLatLng.longitude,
        destLat: destLatLng.latitude,
        destLng: destLatLng.longitude,
      );

      // 3. Retrieve/generate dynamic user circular marker and destination marker
      final currentMarker = await _markerService.generateMarker(
        type: MapMarkerType.current,
        position: originLatLng,
        heading: _lastHeading,
      );

      final destMarker = await _markerService.generateMarker(
        type: MapMarkerType.destination,
        position: destLatLng,
        title: AppStrings.customDestinationTitle,
      );

      // 4. Create path polyline
      final routePolyline = _polylineService.generateRoutePolyline(
        route.polylinePoints,
      );

      // 5. Emit new loaded state
      emit(
        currentState.copyWith(
          currentLocation: originLatLng,
          destinationLocation: destLatLng,
          routeInfo: route,
          markers: {currentMarker, destMarker},
          polylines: {routePolyline},
          isRouting: false,
          clearLongPressLatLng: true,
        ),
      );

      // 6. Focus camera on the user in 3D navigation perspective immediately
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: originLatLng,
            zoom: AppSizes.navigationZoom,
            tilt: AppSizes.navigationTilt,
            bearing: _lastHeading,
          ),
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isRouting: false));
      rethrow;
    }
  }

  /// Centers the camera on the user's current GPS coordinates, acting like 3D navigation if routing.
  Future<void> recenterOnUser() async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    // Reset auto centering state so map tracks location again
    emit(currentState.copyWith(isAutoCenteringDisabled: false));

    if (currentState.currentLocation != null) {
      if (currentState.destinationLocation != null) {
        // acts like map navigation: tight zoom, 3D tilt perspective, aligned direction-facing bearing
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentState.currentLocation!,
              zoom: AppSizes.navigationZoom,
              tilt: AppSizes.navigationTilt,
              bearing: _lastHeading,
            ),
          ),
        );
      } else {
        // Normal flat overview recenter
        _animateToLocation(currentState.currentLocation!, zoom: AppSizes.defaultUserZoom);
      }
    }
  }

  /// Disables auto-centering (e.g. if the user drags or zooms on map during routing).
  void disableAutoCentering() {
    final currentState = state;
    if (currentState is MapLoaded && !currentState.isAutoCenteringDisabled) {
      emit(currentState.copyWith(isAutoCenteringDisabled: true));
    }
  }

  /// Sets the coordinates of a user's map long-press gesture.
  void setLongPressLatLng(LatLng latLng) {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(selectedLongPressLatLng: latLng));
    }
  }

  /// Clears the long-press coordinate state.
  void clearLongPressLatLng() {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(clearLongPressLatLng: true));
    }
  }

  /// Clears the active routing destination, polyline, and HUD overlays.
  void clearRoute() {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    // Remove destination marker and route polylines
    final Set<Marker> updatedMarkers = Set.from(currentState.markers)
      ..removeWhere((m) => m.markerId.value == AppStrings.markerIdDestination);

    emit(
      currentState.copyWith(
        clearDestination: true,
        clearRouteInfo: true,
        markers: updatedMarkers,
        polylines: {},
        predictions: [],
      ),
    );

    // Animate camera back to user's location smoothly
    if (currentState.currentLocation != null) {
      _animateToLocation(currentState.currentLocation!, zoom: AppSizes.defaultUserZoom);
    }
  }

  /// Clears the transient arrival message from state.
  void clearArrivalMessage() {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(clearArrivalMessage: true));
    }
  }

  /// Internal helper to animate camera to specific [LatLng]
  void _animateToLocation(
    LatLng target, {
    required double zoom,
    double tilt = AppSizes.initialTilt,
    double bearing = AppSizes.defaultHeading,
  }) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: zoom,
          tilt: tilt,
          bearing: bearing,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}

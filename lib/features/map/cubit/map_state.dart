import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain/entities/place_prediction.dart';
import '../domain/entities/route_info.dart';

abstract class MapState {
  const MapState();
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  final String? message;
  const MapLoading({this.message});
}

class MapLoaded extends MapState {
  final LatLng? currentLocation;
  final LatLng? destinationLocation;
  final List<PlacePrediction> predictions;
  final RouteInfo? routeInfo;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool isSearching;
  final bool isRouting;
  final String? arrivalMessage;
  final LatLng? selectedLongPressLatLng;
  final bool isAutoCenteringDisabled;

  const MapLoaded({
    this.currentLocation,
    this.destinationLocation,
    this.predictions = const [],
    this.routeInfo,
    this.markers = const {},
    this.polylines = const {},
    this.isSearching = false,
    this.isRouting = false,
    this.arrivalMessage,
    this.selectedLongPressLatLng,
    this.isAutoCenteringDisabled = false,
  });

  MapLoaded copyWith({
    LatLng? currentLocation,
    LatLng? destinationLocation,
    List<PlacePrediction>? predictions,
    RouteInfo? routeInfo,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    bool? isSearching,
    bool? isRouting,
    String? arrivalMessage,
    LatLng? selectedLongPressLatLng,
    bool? isAutoCenteringDisabled,
    bool clearDestination = false,
    bool clearRouteInfo = false,
    bool clearArrivalMessage = false,
    bool clearLongPressLatLng = false,
  }) {
    return MapLoaded(
      currentLocation: currentLocation ?? this.currentLocation,
      destinationLocation: clearDestination ? null : (destinationLocation ?? this.destinationLocation),
      predictions: predictions ?? this.predictions,
      routeInfo: clearRouteInfo ? null : (routeInfo ?? this.routeInfo),
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      isSearching: isSearching ?? this.isSearching,
      isRouting: isRouting ?? this.isRouting,
      arrivalMessage: clearArrivalMessage ? null : (arrivalMessage ?? this.arrivalMessage),
      selectedLongPressLatLng: clearLongPressLatLng ? null : (selectedLongPressLatLng ?? this.selectedLongPressLatLng),
      isAutoCenteringDisabled: isAutoCenteringDisabled ?? this.isAutoCenteringDisabled,
    );
  }
}

class MapError extends MapState {
  final String errorMessage;
  const MapError(this.errorMessage);
}

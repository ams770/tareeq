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
    bool clearDestination = false,
    bool clearRouteInfo = false,
    bool clearArrivalMessage = false,
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
    );
  }
}

class MapError extends MapState {
  final String errorMessage;
  const MapError(this.errorMessage);
}

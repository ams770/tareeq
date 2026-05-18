import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_strings.dart';
import '../constants/assets_manager.dart';
import '../constants/app_sizes.dart';
import '../utils/marker_generator.dart';

/// Enum to distinguish between user's current location marker and selected destination marker.
enum MapMarkerType {
  current,
  destination,
}

/// Interface contract for generating and styling Google Map Markers asynchronously.
abstract class MarkerService {
  /// Generates a styled Google Map [Marker] based on type and custom parameters.
  Future<Marker> generateMarker({
    required MapMarkerType type,
    required LatLng position,
    double heading = 0.0,
    String? title,
    String? snippet,
  });
}

/// Concrete implementation of the [MarkerService] interface.
class MarkerServiceImpl implements MarkerService {
  @override
  Future<Marker> generateMarker({
    required MapMarkerType type,
    required LatLng position,
    double heading = 0.0,
    String? title,
    String? snippet,
  }) async {
    switch (type) {
      case MapMarkerType.current:
        final circularIcon = await MarkerGenerator.createDirectionalMarkerIcon(heading);
        return Marker(
          markerId: const MarkerId(AppStrings.markerIdCurrent),
          position: position,
          infoWindow: const InfoWindow(title: AppStrings.myLocationTitle),
          icon: circularIcon,
          anchor: const Offset(0.5, 0.5),
        );
      case MapMarkerType.destination:
        final pinIcon = await BitmapDescriptor.asset(
          const ImageConfiguration(
            size: Size(AppSizes.destinationMarkerWidth, AppSizes.destinationMarkerHeight),
          ),
          AssetsManager.pin,
        );
        return Marker(
          markerId: const MarkerId(AppStrings.markerIdDestination),
          position: position,
          infoWindow: InfoWindow(
            title: title ?? AppStrings.customDestinationTitle,
            snippet: snippet,
          ),
          icon: pinIcon,
        );
    }
  }
}

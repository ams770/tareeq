import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/polyline_decoder.dart';
import '../../domain/entities/route_info.dart';

class RouteInfoModel extends RouteInfo {
  const RouteInfoModel({
    required super.polylinePoints,
    required super.distanceText,
    required super.durationText,
    required super.bounds,
  });

  factory RouteInfoModel.fromJson(Map<String, dynamic> json) {
    // 1. Parse Bounds
    final boundsJson = json['bounds'] as Map<String, dynamic>? ?? {};
    final neJson = boundsJson['northeast'] as Map<String, dynamic>? ?? {};
    final swJson = boundsJson['southwest'] as Map<String, dynamic>? ?? {};

    final northeast = LatLng(
      (neJson['lat'] as num? ?? 0.0).toDouble(),
      (neJson['lng'] as num? ?? 0.0).toDouble(),
    );
    final southwest = LatLng(
      (swJson['lat'] as num? ?? 0.0).toDouble(),
      (swJson['lng'] as num? ?? 0.0).toDouble(),
    );

    final bounds = LatLngBounds(
      southwest: southwest,
      northeast: northeast,
    );

    // 2. Parse distance & duration from legs
    final legs = json['legs'] as List<dynamic>? ?? [];
    String distanceText = '';
    String durationText = '';

    if (legs.isNotEmpty) {
      final leg = legs.first as Map<String, dynamic>;
      final distance = leg['distance'] as Map<String, dynamic>? ?? {};
      final duration = leg['duration'] as Map<String, dynamic>? ?? {};

      distanceText = distance['text'] as String? ?? '';
      durationText = duration['text'] as String? ?? '';
    }

    // 3. Parse and decode Polyline
    final polylineJson = json['overview_polyline'] as Map<String, dynamic>? ?? {};
    final encodedPoints = polylineJson['points'] as String? ?? '';
    final decodedPoints = PolylineDecoder.decode(encodedPoints);

    return RouteInfoModel(
      polylinePoints: decodedPoints,
      distanceText: distanceText,
      durationText: durationText,
      bounds: bounds,
    );
  }
}

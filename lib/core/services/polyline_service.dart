import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// Interface defining the contract for managing maps polyline styling and rendering logic.
abstract class PolylineService {
  /// Generates a styled Google Map Polyline path based on the list of LatLng points.
  Polyline generateRoutePolyline(List<LatLng> points);
}

/// Concrete implementation of the [PolylineService] interface.
class PolylineServiceImpl implements PolylineService {
  @override
  Polyline generateRoutePolyline(List<LatLng> points) {
    return Polyline(
      polylineId: const PolylineId(AppStrings.polylineIdRoute),
      points: points,
      color: AppColors.navigationBlue,
      width: 6,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }
}

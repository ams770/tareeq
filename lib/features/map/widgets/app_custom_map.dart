import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_sizes.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';

class AppCustomMap extends StatefulWidget {
  final MapLoaded state;

  const AppCustomMap({
    super.key,
    required this.state,
  });

  @override
  State<AppCustomMap> createState() => _AppCustomMapState();
}

class _AppCustomMapState extends State<AppCustomMap> {
  bool _isUserInteracting = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        _isUserInteracting = true;
      },
      onPointerUp: (_) {
        _isUserInteracting = false;
      },
      onPointerCancel: (_) {
        _isUserInteracting = false;
      },
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.state.currentLocation ?? const LatLng(0, 0),
          zoom: AppSizes.initialZoom,
          tilt: AppSizes.initialTilt,
        ),
        onMapCreated: (GoogleMapController controller) {
          context.read<MapCubit>().mapController = controller;
        },
        markers: widget.state.markers,
        polylines: widget.state.polylines,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
        buildingsEnabled: true,
        onLongPress: (LatLng latLng) {
          context.read<MapCubit>().setLongPressLatLng(latLng);
        },
        onCameraMove: (position) {
          if (_isUserInteracting && widget.state.destinationLocation != null) {
            context.read<MapCubit>().disableAutoCentering();
          }
        },
      ),
    );
  }
}

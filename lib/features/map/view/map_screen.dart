import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/assets_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_card.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../widgets/map_error_widget.dart';
import '../widgets/map_loading_widget.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/predictions_list.dart';
import '../widgets/recenter_button.dart';
import '../widgets/route_summary_hud.dart';
import '../widgets/long_press_options_nav_bar.dart';
import '../widgets/arrival_nav_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLongPressLatLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapCubit>().initializeMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<MapCubit, MapState>(
        listener: (context, state) {
          if (state is MapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MapLoading) {
            return MapLoadingWidget(
              message: state.message ?? AppStrings.defaultLoading,
            );
          }

          if (state is MapError) {
            return MapErrorWidget(errorMessage: state.errorMessage);
          }

          if (state is MapLoaded) {
            final bool showBottomNav = (state.arrivalMessage != null || _selectedLongPressLatLng != null);

            return Stack(
              children: [
                // 1. Full Screen Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: state.currentLocation ?? const LatLng(0, 0),
                    zoom: AppSizes.initialZoom,
                    tilt: AppSizes.initialTilt,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    context.read<MapCubit>().mapController = controller;
                  },
                  markers: state.markers,
                  polylines: state.polylines,
                  myLocationEnabled: false, // We use our custom styled cyan marker instead
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  buildingsEnabled: true, 
                  onLongPress: (LatLng latLng) {
                    setState(() {
                      _selectedLongPressLatLng = latLng;
                    });
                  },
                ),

                // 2. Floating Search Field & Predictions List
                if (state.routeInfo == null && _selectedLongPressLatLng == null && state.arrivalMessage == null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + AppSizes.padding16,
                    left: AppSizes.padding16,
                    right: AppSizes.padding16,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [MapSearchBar(), PredictionsList()],
                    ),
                  ),

                // 3. Floating GPS Recenter Button (shifted dynamically if bottom nav is shown)
                Positioned(
                  bottom: showBottomNav ? AppSizes.recenterShiftedBottom : AppSizes.recenterDefaultBottom,
                  right: AppSizes.padding16,
                  child: const RecenterButton(),
                ),

                // 4. Floating Route Details HUD (Distance & Duration Summary)
                if (state.routeInfo != null && !showBottomNav)
                  Positioned(
                    bottom: AppSizes.recenterDefaultBottom,
                    left: AppSizes.padding16,
                    right: AppSizes.padding88, // Offsets slightly to make space for recenter button
                    child: RouteSummaryHud(
                      distance: state.routeInfo!.distanceText,
                      duration: state.routeInfo!.durationText,
                    ),
                  ),

                // 5. Lottie Loader Overlay during route calculation
                if (state.isRouting)
                  Container(
                    color: Colors.black.withOpacity(0.25),
                    child: Center(
                      child: PremiumCard(
                        width: AppSizes.lottieContainerSize,
                        height: AppSizes.lottieContainerSize,
                        borderRadius: AppSizes.padding24,
                        child: Center(
                          child: Lottie.asset(
                            AssetsManager.locationLoading,
                            width: AppSizes.lottieIconSize,
                            height: AppSizes.lottieIconSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 5.5 Darker Modal Barrier when bottom sheet is open
                if (showBottomNav)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLongPressLatLng = null;
                        });
                        if (state.arrivalMessage != null) {
                          context.read<MapCubit>().clearArrivalMessage();
                        }
                      },
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ),

                // 6. Long Press Options Bottom Navigation Bar
                if (_selectedLongPressLatLng != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LongPressOptionsNavBar(
                      position: _selectedLongPressLatLng!,
                      onCancel: () {
                        setState(() {
                          _selectedLongPressLatLng = null;
                        });
                      },
                      onConfirm: () {
                        final target = _selectedLongPressLatLng!;
                        setState(() {
                          _selectedLongPressLatLng = null;
                        });
                        context.read<MapCubit>().selectLatLngDestination(target);
                      },
                    ),
                  ),

                // 7. Arrival Bottom Navigation Bar
                if (state.arrivalMessage != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ArrivalNavBar(
                      onDismiss: () {
                        context.read<MapCubit>().clearArrivalMessage();
                      },
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

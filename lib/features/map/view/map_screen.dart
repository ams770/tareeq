import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
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
import '../widgets/app_custom_map.dart';
import '../widgets/route_calculation_loader.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

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
            final bool showBottomNav = (state.arrivalMessage != null || state.selectedLongPressLatLng != null);
            final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

            return Stack(
              children: [
                // 1. Full Screen Google Map (extracted reusable component)
                AppCustomMap(state: state),

                // 2. Floating Search Field & Predictions List
                if (state.routeInfo == null && state.selectedLongPressLatLng == null && state.arrivalMessage == null)
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
                // Positioned within a safe area from the bottom plus vertical padding
                Positioned(
                  bottom: (showBottomNav ? AppSizes.recenterShiftedBottom : AppSizes.recenterDefaultBottom) + bottomSafeArea,
                  right: AppSizes.padding16,
                  child: const RecenterButton(),
                ),

                // 4. Floating Route Details HUD (Distance & Duration Summary)
                // Positioned within a safe area from the bottom plus vertical padding
                if (state.routeInfo != null && !showBottomNav)
                  Positioned(
                    bottom: AppSizes.recenterDefaultBottom + bottomSafeArea,
                    left: AppSizes.padding16,
                    right: AppSizes.padding88, // Offsets slightly to make space for recenter button
                    child: RouteSummaryHud(
                      distance: state.routeInfo!.distanceText,
                      duration: state.routeInfo!.durationText,
                    ),
                  ),

                // 5. Lottie Loader Overlay during route calculation (extracted reusable component)
                if (state.isRouting)
                  const RouteCalculationLoader(),

                // 5.5 Darker Modal Barrier when bottom sheet is open
                if (showBottomNav)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        context.read<MapCubit>().clearLongPressLatLng();
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
                if (state.selectedLongPressLatLng != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LongPressOptionsNavBar(
                      position: state.selectedLongPressLatLng!,
                      onCancel: () {
                        context.read<MapCubit>().clearLongPressLatLng();
                      },
                      onConfirm: () {
                        final target = state.selectedLongPressLatLng!;
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

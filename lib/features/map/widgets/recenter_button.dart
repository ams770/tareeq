import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_card.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';

class RecenterButton extends StatelessWidget {
  const RecenterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        final bool isRouting = state is MapLoaded && state.isRouting;

        return FloatingActionButton(
          onPressed: isRouting
              ? null
              : () async {
                  try {
                    await context.read<MapCubit>().recenterOnUser();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${AppStrings.errorFailedFetchGps}$e',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          child: PremiumCard(
            borderRadius: 30.0,
            width: 56,
            height: 56,
            child: Center(
              child: isRouting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : const Icon(
                      Icons.gps_fixed_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
            ),
          ),
        );
      },
    );
  }
}

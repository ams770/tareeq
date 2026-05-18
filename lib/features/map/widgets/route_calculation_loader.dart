import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/assets_manager.dart';
import '../../../core/theme/app_colors.dart';

class RouteCalculationLoader extends StatelessWidget {
  const RouteCalculationLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.25),
      child: Center(
        child: SizedBox(
          width: AppSizes.lottieContainerSize,
          height: AppSizes.lottieContainerSize,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.padding24),
              side: const BorderSide(
                color: AppColors.cardBorder,
                width: 1.0,
              ),
            ),
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
    );
  }
}

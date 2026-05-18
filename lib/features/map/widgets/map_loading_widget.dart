import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/assets_manager.dart';
import '../../../core/theme/app_colors.dart';

class MapLoadingWidget extends StatelessWidget {
  final String message;

  const MapLoadingWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AssetsManager.locationLoading,
            width: 260,
            height: 260,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

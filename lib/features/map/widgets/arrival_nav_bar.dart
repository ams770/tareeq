import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ArrivalNavBar extends StatelessWidget {
  final VoidCallback onDismiss;

  const ArrivalNavBar({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.padding24),
          topRight: Radius.circular(AppSizes.padding24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppSizes.padding24,
        right: AppSizes.padding24,
        top: AppSizes.padding20,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.padding16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: AppSizes.bottomBarPillWidth,
              height: AppSizes.bottomBarPillHeight,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.padding16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.padding10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: AppSizes.iconSize28,
                ),
              ),
              const SizedBox(width: AppSizes.padding12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination Reached!',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'You have arrived. You are at the point.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.padding16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.padding14),
                ),
              ),
              child: const Text(
                'Awesome!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

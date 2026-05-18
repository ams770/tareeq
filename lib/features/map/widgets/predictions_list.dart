import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';

class PredictionsList extends StatelessWidget {
  const PredictionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        if (state is! MapLoaded || state.predictions.isEmpty) {
          return const SizedBox.shrink();
        }

        final predictions = state.predictions;

        return Card(
          margin: const EdgeInsets.only(top: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(
              color: AppColors.cardBorder,
              width: 1.0,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: predictions.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.cardBorder,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final prediction = predictions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    radius: 18,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    prediction.mainText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    prediction.secondaryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    // Trigger selection and details fetching
                    context.read<MapCubit>().selectPrediction(prediction);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const PremiumCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

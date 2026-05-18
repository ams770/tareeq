import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

class MarkerGenerator {
  /// Generates a premium dynamic neon cyan circle marker with a directional arrow.
  /// [heading] is the bearing direction (0 to 360 degrees).
  static Future<BitmapDescriptor> createDirectionalMarkerIcon(double heading) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = AppSizes.currentUserMarkerSize;
    const double radius = AppSizes.currentUserRadius;

    // 1. Draw outer glowing translucent circle (navigation blue glow)
    final Paint glowPaint = Paint()
      ..color = AppColors.navigationBlue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), radius + AppSizes.currentUserGlowRadiusDelta, glowPaint);

    // 2. Draw white outline for the core marker circle
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.currentUserStrokeWidth;
    canvas.drawCircle(const Offset(size / 2, size / 2), radius, borderPaint);

    // 3. Draw inner filled navigation blue circle
    final Paint circlePaint = Paint()
      ..color = AppColors.navigationBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), radius - AppSizes.currentUserStrokeWidth, circlePaint);

    // 4. Draw heading direction indicator (chevron/arrow)
    canvas.save();
    canvas.translate(size / 2, size / 2);
    final double radians = (heading * pi) / 180.0;
    canvas.rotate(radians);

    final Path arrowPath = Path();
    // Chevron pointing UP
    arrowPath.moveTo(0, -radius - 6);  // tip
    arrowPath.lineTo(-4, -radius + 1.2); // left base
    arrowPath.lineTo(4, -radius + 1.2);  // right base
    arrowPath.close();

    final Paint arrowPaint = Paint()
      ..color = AppColors.navigationBlue
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowPaint);

    // Inner white arrow tip
    final Path innerArrowPath = Path();
    innerArrowPath.moveTo(0, -radius - 3.5);
    innerArrowPath.lineTo(-2.5, -radius + 0.6);
    innerArrowPath.lineTo(2.5, -radius + 0.6);
    innerArrowPath.close();
    
    final Paint innerArrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerArrowPath, innerArrowPaint);

    canvas.restore();

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }
}

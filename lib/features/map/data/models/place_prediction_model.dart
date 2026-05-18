import '../../domain/entities/place_prediction.dart';

class PlacePredictionModel extends PlacePrediction {
  const PlacePredictionModel({
    required super.placeId,
    required super.description,
    required super.mainText,
    required super.secondaryText,
  });

  factory PlacePredictionModel.fromJson(Map<String, dynamic> json) {
    final formatting = json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return PlacePredictionModel(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: formatting['main_text'] as String? ?? '',
      secondaryText: formatting['secondary_text'] as String? ?? '',
    );
  }
}

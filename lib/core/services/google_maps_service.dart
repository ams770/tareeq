import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

class GoogleMapsService {
  final http.Client _client;

  GoogleMapsService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches place predictions as the user types.
  /// Uses a [sessionToken] for billing aggregation.
  Future<List<dynamic>> getAutocompletePredictions(String input, String sessionToken) async {
    if (input.trim().isEmpty) return [];

    final url = Uri.parse(
      '${AppConstants.placesAutocompleteUrl}'
      '?input=${Uri.encodeComponent(input)}'
      '&key=${AppConstants.googleMapsApiKey}'
      '&sessiontoken=$sessionToken'
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String status = data[AppStrings.keyStatus] ?? AppStrings.empty;

        if (status == AppStrings.statusOk) {
          return data[AppStrings.keyPredictions] as List<dynamic>;
        } else if (status == AppStrings.statusZeroResults) {
          return [];
        } else {
          throw Exception('${AppStrings.errorGooglePlacesApi}$status. ${data[AppStrings.keyErrorMessage] ?? AppStrings.empty}');
        }
      } else {
        throw Exception('${AppStrings.errorFailedLoadPredictions}${response.statusCode}');
      }
    } catch (e) {
      throw Exception('${AppStrings.errorNetwork}$e');
    }
  }

  /// Fetches place geometry (latitude and longitude) using a [placeId].
  Future<Map<String, dynamic>> getPlaceGeometry(String placeId) async {
    final url = Uri.parse(
      '${AppConstants.placeDetailsUrl}'
      '?place_id=$placeId'
      '&fields=${AppConstants.keyGeometry}'
      '&key=${AppConstants.googleMapsApiKey}'
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String status = data[AppStrings.keyStatus] ?? AppStrings.empty;

        if (status == AppStrings.statusOk) {
          final result = data[AppStrings.keyResult] as Map<String, dynamic>;
          final geometry = result[AppConstants.keyGeometry] as Map<String, dynamic>;
          final location = geometry[AppStrings.keyLocation] as Map<String, dynamic>;
          return {
            AppStrings.keyLat: (location[AppStrings.keyLat] as num).toDouble(),
            AppStrings.keyLng: (location[AppStrings.keyLng] as num).toDouble(),
          };
        } else {
          throw Exception('Google Place Details API Error: $status. ${data[AppStrings.keyErrorMessage] ?? AppStrings.empty}');
        }
      } else {
        throw Exception('${AppStrings.errorFailedLoadPlaceDetails}${response.statusCode}');
      }
    } catch (e) {
      throw Exception('${AppStrings.errorNetwork}$e');
    }
  }
}

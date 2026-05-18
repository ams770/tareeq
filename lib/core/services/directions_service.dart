import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

class DirectionsService {
  final http.Client _client;

  DirectionsService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches routing directions from [originLat, originLng] to [destLat, destLng].
  /// Returns raw parsed JSON containing bounds, polyline, and leg information.
  Future<Map<String, dynamic>> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Uri.parse(
      '${AppConstants.directionsUrl}'
      '?origin=$originLat,$originLng'
      '&destination=$destLat,$destLng'
      '&key=${AppConstants.googleMapsApiKey}'
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String status = data[AppStrings.keyStatus] ?? AppStrings.empty;

        if (status == AppStrings.statusOk) {
          final List<dynamic> routes = data[AppStrings.keyRoutes] as List<dynamic>;
          if (routes.isNotEmpty) {
            return routes.first as Map<String, dynamic>;
          } else {
            throw Exception(AppStrings.errorNoRoutes);
          }
        } else {
          throw Exception('${AppStrings.errorGoogleDirectionsApi}$status. ${data[AppStrings.keyErrorMessage] ?? AppStrings.empty}');
        }
      } else {
        throw Exception('${AppStrings.errorFailedLoadDirections}${response.statusCode}');
      }
    } catch (e) {
      throw Exception('${AppStrings.errorNetwork}$e');
    }
  }
}

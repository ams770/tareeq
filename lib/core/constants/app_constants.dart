import 'app_secrets.dart';

class AppConstants {
  // Google Maps API Key — loaded from dynamically generated app_secrets.dart
  // Never hardcode the real key here.
  static const String googleMapsApiKey = AppSecrets.googleMapsApiKey;

  // Base API URLs
  static const String placesAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String placeDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String directionsUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  // API parameters
  static const String keyGeometry = 'geometry';
}


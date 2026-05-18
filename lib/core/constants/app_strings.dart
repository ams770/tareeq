class AppStrings {
  // Empty String
  static const String empty = '';
  static const String underscore = '_';

  // Application Shell Strings
  static const String appTitle = 'Tareeq Route Finder';
  static const String defaultRoute = '/';

  // API Parameters & Key Strings
  
  static const String keyLocation = 'location';
  static const String keyLat = 'lat';
  static const String keyLng = 'lng';
  static const String keyStatus = 'status';
  static const String keyPredictions = 'predictions';
  static const String keyErrorMessage = 'error_message';
  static const String keyPlaceId = 'place_id';
  static const String keyDescription = 'description';
  static const String keyStructuredFormatting = 'structured_formatting';
  static const String keyMainText = 'main_text';
  static const String keySecondaryText = 'secondary_text';
  static const String keyResult = 'result';
  static const String keyRoutes = 'routes';
  static const String keyBounds = 'bounds';
  static const String keyNortheast = 'northeast';
  static const String keySouthwest = 'southwest';
  static const String keyLegs = 'legs';
  static const String keyDistance = 'distance';
  static const String keyDuration = 'duration';
  static const String keyText = 'text';
  static const String keyOverviewPolyline = 'overview_polyline';
  static const String keyPoints = 'points';
  static const String markerIdCurrent = 'current_location';
  static const String markerIdDestination = 'destination_location';
  static const String polylineIdRoute = 'route_path';

  // Status Responses
  static const String statusOk = 'OK';
  static const String statusZeroResults = 'ZERO_RESULTS';

  // User Interface Labels
  static const String searchHint = 'Search for destination...';
  static const String defaultLoading = 'Loading...';
  static const String locatingUser = 'Requesting GPS permissions and locating...';
  static const String myLocationTitle = 'Your Location';
  static const String permissionErrorTitle = 'Permission or Location Error';
  static const String btnRetrySetup = 'Retry Setup';
  static const String btnCancel = 'Cancel';
  static const String distanceLabel = 'Distance: ';
  static const String arrivalMessageText = 'You have arrived!';
  static const String customDestinationTitle = 'Selected Point';
  static const String navigationDialogTitle = 'Start Navigation?';
  static const String navigationDialogContent = 'Do you want to start navigation to this custom selected point?';
  static const String btnYes = 'Yes';
  static const String btnNo = 'No';

  // Error Messages
  static const String errorLocationPermissionDenied = 'Location permission is denied.';
  static const String errorGooglePlacesApi = 'Google Places API Error: ';
  static const String errorFailedLoadPredictions = 'Failed to load predictions. HTTP Status: ';
  static const String errorNetwork = 'Network Error: ';
  static const String errorFailedLoadPlaceDetails = 'Failed to load place details. HTTP Status: ';
  static const String errorFailedLoadDirections = 'Failed to load directions. HTTP Status: ';
  static const String errorNoRoutes = 'No routes found.';
  static const String errorGoogleDirectionsApi = 'Google Directions API Error: ';
  static const String errorCouldNotAccessLocation = 'Could not access current location: ';
  static const String errorFailedSearchPlaces = 'Failed to search places: ';
  static const String errorFailedFetchPlaceDetails = 'Failed to fetch place details: ';
  static const String errorFailedFetchRouteDirections = 'Failed to fetch route directions: ';
  static const String errorFailedGetCurrentLocation = 'Failed to get current location: ';
  static const String errorFailedFetchGps = 'Failed to fetch GPS location: ';

}

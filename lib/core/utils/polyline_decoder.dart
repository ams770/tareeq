import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineDecoder {
  /// Decodes a Google encoded polyline string into a list of [LatLng] coordinates.
  static List<LatLng> decode(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double finalLat = lat / 1E5;
      double finalLng = lng / 1E5;
      polylinePoints.add(LatLng(finalLat, finalLng));
    }

    return polylinePoints;
  }
}

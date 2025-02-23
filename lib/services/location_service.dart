import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Request permissions
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false; // Permission denied
      }
    }
    return permission != LocationPermission.deniedForever;
  }

  // Get current country
  static Future<String?> getCurrentCountry() async {
    bool hasPermission = await requestPermission();
    if (!hasPermission) return null;

    Position position = await Geolocator.getCurrentPosition();

    // Reverse geocoding to get country from coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      return placemarks.first.isoCountryCode; // Returns country code (e.g., "US", "IT")
    }
    return null;
  }
}

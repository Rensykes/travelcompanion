import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Request permissions
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      log("Location permission permanently denied. Redirecting to settings...");
      await Geolocator.openAppSettings(); // Open settings page
      return false;
    }

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  // Get current country
  static Future<String?> getCurrentCountry() async {
    bool hasPermission = await requestPermission();
    if (!hasPermission) return null;

    Position? position = await Geolocator.getCurrentPosition();

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return placemarks.isNotEmpty ? placemarks.first.isoCountryCode : null;
  }
}

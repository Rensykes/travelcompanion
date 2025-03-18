import 'dart:developer';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Method to open location settings
  static Future<void> openLocationSettings() async {
    if (Platform.isAndroid) {
      await AppSettings.openAppSettings();
    } else if (Platform.isIOS) {
      await openAppSettings();
    }
  }
  
  // You might also want to add a method to check location permissions
  static Future<bool> checkLocationPermission() async {
    PermissionStatus status = await Permission.locationAlways.status;
    return status.isGranted;
  }


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

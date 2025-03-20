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

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Get current country
  static Future<String?> getCurrentCountry() async {
/*     LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.lowest,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 15),
        //(Optional) Set foreground notification config to keep the app alive
        //when going to the background
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "Example app will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.lowest,
        activityType: ActivityType.other,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = LocationSettings(accuracy: LocationAccuracy.lowest);
    } */


    // // Simplify location settings for background operation
    // LocationSettings locationSettings = LocationSettings(
    //   accuracy: LocationAccuracy.reduced,
    //   distanceFilter: 500,
    //   timeLimit: Duration(seconds: 30), // Avoid hanging
    // );

    LocationSettings locationSettings  = AndroidSettings(
        accuracy: LocationAccuracy.lowest,
        forceLocationManager: true,
        timeLimit: Duration(minutes: 2),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "Example app will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: false,
        ),
    );
    bool hasPermission = await requestPermission();
    if (!hasPermission) return null;

    Position? position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    // Position position = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.low,
    //   forceAndroidLocationManager: true, // Important for background operation
    //   timeLimit: Duration(seconds: 30)
    // );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return placemarks.isNotEmpty ? placemarks.first.isoCountryCode : null;
  }
}

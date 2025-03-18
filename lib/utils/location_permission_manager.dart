import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackie/services/location_service.dart';

class LocationPermissionManager {
  static const String _keyPermissionPrompted = 'permission_prompted';
  static const String _keyPermissionDenied = 'permission_denied';
  static const String _keyFirstLaunch = 'first_launch';
  
  // Check if this is the first launch of the app
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool(_keyFirstLaunch) ?? true;
    
    if (isFirstLaunch) {
      await prefs.setBool(_keyFirstLaunch, false);
      return true;
    }
    return false;
  }
  
  // Check if the permission has been denied before
  static Future<bool> hasPermissionBeenDenied() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPermissionDenied) ?? false;
  }
  
  // Mark that user has denied the permission
  static Future<void> markPermissionDenied() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPermissionDenied, true);
  }
  
  // Mark that user has been prompted for permission
  static Future<void> markPermissionPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPermissionPrompted, true);
  }
  
  // Reset the denied status (e.g., if user grants permission later)
  static Future<void> resetPermissionDenied() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPermissionDenied, false);
  }
  
  // Check if location permission is set to "Always"
  static Future<bool> hasAlwaysLocationPermission() async {
    if (Platform.isAndroid) {
      return await Permission.locationAlways.isGranted;
    } else if (Platform.isIOS) {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always;
    }
    return false;
  }
  
  // Request "Always" location permission
  static Future<bool> requestAlwaysLocationPermission() async {
    if (Platform.isAndroid) {
      // For Android, first request background location
      await Permission.locationWhenInUse.request();
      PermissionStatus status = await Permission.locationAlways.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // For iOS, request always permission via Geolocator
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always;
    }
    return false;
  }
  
  // Open app settings to allow the user to enable permissions
  static Future<void> openAppSettings() async {
    await Permission.locationAlways.request();
    await openAppSettings();
  }
  
  // Complete flow to check and request permission
  // Returns true if permission is granted
  static Future<bool> checkAndRequestPermission(BuildContext context) async {
    // Check current permission status
    bool hasPermission = await hasAlwaysLocationPermission();
    
    if (hasPermission) {
      // Reset denied status if permission is now granted
      await resetPermissionDenied();
      return true;
    }
    
    // Check if this is first launch or permission has been denied
    bool firstLaunch = await isFirstLaunch();
    bool permissionDenied = await hasPermissionBeenDenied();
    
    if (firstLaunch || permissionDenied) {
      // Show dialog explaining why permission is needed
      bool shouldProceed = await _showPermissionRationaleDialog(context, permissionDenied);
      
      if (shouldProceed) {
        // First try requesting through the system UI
        bool granted = await requestAlwaysLocationPermission();
        
        if (!granted) {
          // If not granted, direct to settings
          await _showSettingsDialog(context);
          // Mark that we've prompted
          await markPermissionPrompted();
          return false;
        } else {
          // Permission granted, reset denied status
          await resetPermissionDenied();
          return true;
        }
      } else {
        // User chose not to proceed
        await markPermissionDenied();
        return false;
      }
    }
    
    return false;
  }
  
  // Show a dialog explaining why the permission is needed
  static Future<bool> _showPermissionRationaleDialog(BuildContext context, bool wasAlreadyDenied) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  wasAlreadyDenied 
                    ? 'You previously denied location permission. This app requires "Always" location permission to track countries visited even when the app is closed.'
                    : 'Trackie needs "Always" location permission to track countries you visit even when the app is closed.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Without this permission, the app won\'t be able to automatically record your travels.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Deny'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  // Show a dialog directing the user to settings
  static Future<void> _showSettingsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Location Permission'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'To track countries visited in the background, please set the location permission to "Always Allow" in your device settings.',
                ),
                SizedBox(height: 10),
                Text(
                  'We\'ll now take you to the settings page. Please select "Location" and then choose "Always Allow".',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Later'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                LocationService.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
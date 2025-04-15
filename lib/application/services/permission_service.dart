import 'dart:io';
import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Service for handling permission requests throughout the application.
///
/// This service abstracts the complexity of requesting and checking permissions
/// across different Android versions. It handles:
/// - Storage permission requests (for Android 12 and below)
/// - Media library permission requests (for Android 13+)
/// - Platform-specific permission strategy selection
///
/// It handles the Android permission model changes in SDK 33 (Android 13)
/// where specific permissions replaced the broader storage permission.
class PermissionService {
  /// Requests storage permissions appropriate for the device's Android version.
  ///
  /// For Android 12 (SDK 32) and below, requests the general storage permission.
  /// For Android 13 (SDK 33) and above, returns true immediately since Storage Access
  /// Framework (SAF) is used instead of direct file access permissions.
  ///
  /// Returns:
  /// - true if permission is granted or not needed
  /// - false if permission is denied
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkVersion = androidInfo.version.sdkInt;

    if (sdkVersion < 33) {
      final storage = await Permission.storage.request();
      log(
        "Storage permission status: ${storage.name}",
        name: 'PermissionService',
        level: 0, // INFO
        time: DateTime.now(),
      );
      return storage.isGranted;
    }

    // Android 13+ does not need storage permission when using SAF
    return true;
  }

  /// Requests media library permissions for accessing files.
  ///
  /// For Android 13 (SDK 33) and above, requests specific media library permission.
  /// For Android 12 (SDK 32) and below, delegates to [requestStoragePermission] since
  /// the general storage permission is used instead.
  ///
  /// Returns:
  /// - true if permission is granted
  /// - false if permission is denied
  Future<bool> requestMediaLibraryPermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkVersion = androidInfo.version.sdkInt;

    if (sdkVersion >= 33) {
      final mediaLibrary = await Permission.mediaLibrary.request();
      log(
        "Media library permission status: ${mediaLibrary.name}",
        name: 'PermissionService',
        level: 0, // INFO
        time: DateTime.now(),
      );
      return mediaLibrary.isGranted;
    }

    // For Android 12 and below, use storage permission
    return requestStoragePermission();
  }

  /// Requests the user to disable battery optimization for the app
  /// to enable more reliable background processing.
  ///
  /// Returns:
  /// - true if battery optimization is disabled or the request was shown
  /// - false if the request failed
  Future<bool> requestIgnoreBatteryOptimization() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.ignoreBatteryOptimizations.status;

      if (status.isGranted) {
        log(
          "Battery optimization is already disabled for this app",
          name: 'PermissionService',
          level: 0, // INFO
          time: DateTime.now(),
        );
        return true;
      }

      final result = await Permission.ignoreBatteryOptimizations.request();

      log(
        "Battery optimization exemption request status: ${result.name}",
        name: 'PermissionService',
        level: 0, // INFO
        time: DateTime.now(),
      );

      return result.isGranted;
    } catch (e) {
      log(
        "Failed to request battery optimization exemption",
        name: 'PermissionService',
        error: e,
        level: 900, // ERROR
        time: DateTime.now(),
      );
      return false;
    }
  }
}

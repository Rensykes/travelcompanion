import 'dart:io';
import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  /// Check and request storage permissions
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

  /// Check and request media library permissions
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
}

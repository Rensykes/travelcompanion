import 'dart:developer';
import 'package:country_detector/country_detector.dart';

/// A service that detects the user's SIM and network ISO country codes.
///
/// This service provides functionality to detect a user's current country
/// based on their mobile network connection. It's primarily used for
/// automatic country detection in location tracking.
///
/// It uses the country_detector package which can access:
/// - SIM ISO code - Represents the country where the SIM card was issued (remains constant)
/// - Network ISO code - Indicates the country of the mobile network the user is
///   currently connected to (can change with roaming)
class SimInfoService {
  /// Returns the current network ISO code (based on the network the user is connected to).
  ///
  /// This method attempts to detect the country by checking the mobile network
  /// the device is currently connected to. It prioritizes the network ISO code
  /// since this reflects the user's current location more accurately than the SIM code.
  ///
  /// Returns:
  /// - A two-letter ISO country code (e.g., "US", "FR") if detection is successful
  /// - null if no country code could be detected or if an error occurs
  static Future<String?> getIsoCode() async {
    try {
      final countryDetector = CountryDetector();
      final allCodes = await countryDetector.detectAll();

      if (allCodes.network.isNotEmpty) {
        log(
          '📡 Detected Network ISO Code: ${allCodes.network}',
          name: 'SimInfoService',
        );
        return allCodes.network;
      } else {
        log(
          '⚠️ No network ISO code detected.',
          name: 'SimInfoService',
        );
      }
    } catch (e, stack) {
      log(
        '❌ Failed to get ISO code',
        name: 'SimInfoService',
        error: e,
        stackTrace: stack,
      );
    }

    return null;
  }
}

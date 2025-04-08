import 'dart:developer';
import 'package:country_detector/country_detector.dart';

/// A service that detects the user's SIM and network ISO country codes.
class SimInfoService {
  /// Returns the current network ISO code (based on the network the user is connected to).
  ///
  /// - **SIM ISO Code**: Represents the country where the SIM card was issued (remains constant).
  /// - **Network ISO Code**: Indicates the country of the mobile network the user is currently connected to (can change with roaming).
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

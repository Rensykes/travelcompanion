import 'dart:developer';
import 'package:country_detector/country_detector.dart';

class SimInfoService {
  /// SIM ISO Code:
  /// The SIM ISO code (or Mobile Country Code, MCC) represents the country where the SIM card was issued.
  /// It remains constant regardless of where the user is currently located or which network they are connected to. It reflects the user's home country based on the SIM card they are using.
  /// Network ISO Code:
  ///The network ISO code (also part of the Mobile Network Code, MNC) indicates the specific mobile network operator that the user is currently connected to, along with the MCC.
  /// It changes based on the network the user is connected to, especially when they are roaming in a different country. This code can give insights into the network service provider but does not necessarily reflect the user's current geographical location.

  static Future<String?> getIsoCode() async {
    try {
      final countryDetector = CountryDetector();
      final allCodes = await countryDetector.detectAll();
      if (allCodes.network.isNotEmpty) return allCodes.network;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }
}

import 'dart:developer';
import 'package:country_detector/country_detector.dart';

class SimInfoService {
  static Future<String?> getIsoCode() async {
    try {
      final countryDetector = CountryDetector();
      final allCodes = await countryDetector.detectAll();
      if (allCodes.sim.isNotEmpty) return allCodes.sim;
      if (!allCodes.network.isNotEmpty) return allCodes.network;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }
}

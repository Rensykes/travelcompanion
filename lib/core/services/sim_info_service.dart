import 'package:flutter/services.dart';

class SimInfoService {
  static const platform = MethodChannel('com.trackie/sim_info');

  static Future<String?> getIsoCode() async {
    try {
      final String? isoCode = await platform.invokeMethod('getSimCountryIso');
      return isoCode;
    } on PlatformException catch (e) {
      print('Failed to get SIM country ISO: ${e.message}');
      return null;
    }
  }
}

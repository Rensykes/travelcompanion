import 'dart:developer';
import 'package:hive/hive.dart';
import '../db/location_log.dart';
import '../utils/hive_constants.dart';

class LogService {
  /// Logs a new entry in the `location_logs` box
  static Future<void> logEntry({required String status, String? countryCode}) async {
    try {
      var logBox = await Hive.openBox<LocationLog>(locationLogsBoxName);

      await logBox.add(LocationLog(
        dateTime: DateTime.now(),
        status: status,
        countryCode: countryCode,
      ));

      await logBox.close();
      log("📝 Log Added: Status - $status, Country - ${countryCode ?? 'N/A'}");
    } catch (e) {
      log("❌ Error while logging: $e");
    }
  }
}

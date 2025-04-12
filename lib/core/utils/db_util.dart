class DBUtils {
  // Source
  static const String manualEntry = 'manual';
  static const String scheduledEntry = 'scheduledEntry';
  static const String failedEntry = 'failedEntry';

  static bool isValidStatus(String status) {
    return status == manualEntry || status == scheduledEntry;
  }
}

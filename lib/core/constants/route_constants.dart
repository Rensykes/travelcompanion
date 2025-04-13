class RouteConstants {
  // Main routes
  static const String home = '/';
  static const String logs = '/logs';
  static const String add = '/add';
  static const String settings = '/settings';
  static const String travelHistory = '/travel-history';

  // Nested routes
  static const String relations =
      'relations/:countryCode'; // Used with home as parent
  static const String advancedSettings =
      'advanced'; // Used with settings as parent
  static const String exportImport =
      'export-import'; // Used with settings as parent
  static const String quickLogsAdd =
      'quick-logs-add'; // Used with logs as parent
  static const String manualAdd = 'manual-add'; // Used with logs as parent

  // Full path constants (for direct navigation)
  static const String homeFullPath = '/';
  static const String relationsFullPath = '/relations/:countryCode';
  static const String logsFullPath = '/logs';
  static const String settingsFullPath = '/settings';
  static const String advancedSettingsFullPath = '/settings/advanced';
  static const String calendar = '/calendar';
  static const String travelHistoryFullPath = '/travel-history';
  static const String exportImportFullPath = '/settings/export-import';
  static const String quickLogsAddFullPath = '/add/quick-logs-add';
  static const String manualAddFullPath = '/add/manual-add';

  // Parameter names
  static const String countryCodeParam = 'countryCode';

  // Helper method to get route name without leading slash
  static String getRouteName(String route) {
    return route.startsWith('/') ? route.substring(1) : route;
  }

  // Helper to build relations route with actual country code
  static String buildRelationsRoute(String countryCode) {
    return '/relations/$countryCode';
  }
}

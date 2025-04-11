// lib/core/config/app_config.dart
import 'dart:developer';

import 'package:flutter/services.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  static const _methodChannel = MethodChannel(
    'io.bytebakehouse.trackie/config',
  );

  factory AppConfig() => _instance;

  AppConfig._internal();

  late Environment _environment;
  late String _apiBaseUrl;
  late bool _enableLogs;
  late String _appName;

  Environment get environment => _environment;
  String get apiBaseUrl => _apiBaseUrl;
  bool get enableLogs => _enableLogs;
  String get appName => _appName;

  // Initialize the configuration based on the current flavor
  Future<void> initialize() async {
    try {
      // Get values from Android BuildConfig using MethodChannel
      final Map<dynamic, dynamic> configMap = await _methodChannel.invokeMethod(
        'getConfigValues',
      );

      _apiBaseUrl = configMap['apiBaseUrl'] as String;
      _enableLogs = configMap['enableLogs'] as bool;
      _appName = configMap['appName'] as String;

      // Determine environment from the API URL
      if (_apiBaseUrl.contains('dev-api')) {
        _environment = Environment.dev;
      } else if (_apiBaseUrl.contains('staging-api')) {
        _environment = Environment.staging;
      } else {
        _environment = Environment.prod;
      }

      log('AppConfig initialized: ${_environment.name}');
      log('API URL: $_apiBaseUrl');
    } catch (e) {
      log('Failed to load config: $e');
      // Default values as fallback
      _environment = Environment.dev;
      _apiBaseUrl = 'https://dev-api.example.com/';
      _enableLogs = true;
      _appName = 'Trackie Dev';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:trackie/core/di/dependency_injection.dart';

/// App initialization
class AppInitialization {
  static Future<void> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await DependencyInjection.init();
    } catch (e) {
      throw Exception('Failed to initialize app: $e');
    }
  }
}

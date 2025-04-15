import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/core/scheduler/background_task.dart';

/// App initialization
class AppInitialization {
  static Future<void> init({required bool isDebugMode}) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await DependencyInjection.init();

      // Note: We don't initialize Workmanager here yet
      // It will be done after the UI is shown and permission is requested
      log(
        "App initialization completed successfully",
        name: 'AppInitialization',
        level: 0, // INFO
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "Failed to initialize app",
        name: 'AppInitialization',
        error: e,
        level: 1000, // ERROR
        time: DateTime.now(),
      );
      throw Exception('Failed to initialize app: $e');
    }
  }

  /// Initialize the background task scheduler
  /// This should be called after the app UI is initialized and
  /// battery optimization permissions have been requested
  static void initializeBackgroundTasks({required bool isDebugMode}) {
    try {
      initializeWorkmanager(isInDebugMode: isDebugMode);
      log(
        "Background tasks initialized successfully",
        name: 'AppInitialization',
        level: 0, // INFO
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "Failed to initialize background tasks",
        name: 'AppInitialization',
        error: e,
        level: 900, // ERROR
        time: DateTime.now(),
      );
    }
  }
}

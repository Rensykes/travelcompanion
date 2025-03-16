// lib/utils/app_initializer.dart
import 'dart:developer';
import '../database/database.dart';

late AppDatabase database;

Future<void> initializeApp() async {
  try {
    // Initialize the database
    database = AppDatabase();
    log("✅ Database initialized successfully");
  } catch (e, stackTrace) {
    throw AppInitializationException(
      'Failed to initialize app: $e',
      stackTrace,
    );
  }
}

class AppInitializationException implements Exception {
  final String message;
  final StackTrace stackTrace;

  AppInitializationException(this.message, this.stackTrace);

  @override
  String toString() => message;
}
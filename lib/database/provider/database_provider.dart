import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/database/database.dart';
import 'package:trackie/utils/exceptions/app_inizialization_exception.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  try {
    // Initialize the database
    AppDatabase database = AppDatabase();
    log("✅ Database initialized successfully");
    return database;
  } catch (e, stackTrace) {
    throw AppInitializationException(
      'Failed to initialize app: $e',
      stackTrace,
    );
  }
}
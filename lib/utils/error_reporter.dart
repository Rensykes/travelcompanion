// utils/error_reporter.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../main.dart';  // For navigatorKey

class ErrorReporter {
  static void reportError(Object error, [StackTrace? stackTrace]) {
    // Log the error
    _logError(error, stackTrace);
    
    // Show user-friendly message
    _showErrorToUser(error);
    
    // In production, you might want to send to a service like Firebase Crashlytics
    if (!kDebugMode) {
      // TODO: Add your production error reporting service here
      // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  static void _logError(Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      log('Error: $error');
      if (stackTrace != null) log('StackTrace: $stackTrace');
    }
  }

  static void _showErrorToUser(Object error) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getUserFriendlyMessage(error)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  static String _getUserFriendlyMessage(Object error) {
    if (error is AppInitializationException) {
      return 'Unable to start the app. Please try again.';
    }
    
    // Add more specific error messages based on error type
    return 'An unexpected error occurred. Please try again.';
  }
}
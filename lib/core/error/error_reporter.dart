import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ErrorReporter {
  static void reportError(BuildContext? context, dynamic error, StackTrace? stackTrace) {
    // Always log the error
    log('Error: $error');
    if (stackTrace != null) {
      log('StackTrace: $stackTrace');
    }

    // Only try to show UI if we have a context
    if (context != null) {
      _showErrorToUser(context, error);
    }
  }

  static void _showErrorToUser(BuildContext context, dynamic error) {
    // Use post-frame callback to avoid showing SnackBar during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Check if the context is still valid
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${error.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }
}
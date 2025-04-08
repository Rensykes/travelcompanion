import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ErrorReporter {
  /// Reports the error to the console and shows a message to the user.
  static void reportError(
    BuildContext? context,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    // Always log the error with detailed context
    log(
      'Error occurred: $error',
      name: 'ErrorReporter',
      error: error,
      stackTrace: stackTrace,
    );

    // Only try to show UI if we have a valid context
    if (context != null) {
      _showErrorToUser(context, error);
    }
  }

  /// Displays an error message to the user in the form of a SnackBar.
  static void _showErrorToUser(BuildContext context, dynamic error) {
    // Ensure the SnackBar is shown after the current frame to avoid UI disruption
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Check if the context is still valid before showing SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred: ${error.toString()}',
              maxLines: 2, // Prevents long error messages from overflowing
              overflow: TextOverflow.ellipsis, // Truncates if too long
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }
}

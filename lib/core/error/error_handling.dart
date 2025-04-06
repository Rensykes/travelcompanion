import 'package:flutter/material.dart';
import 'package:trackie/core/error/error_reporter.dart';

void initializeErrorHandling(BuildContext? context) {
  // Set up Flutter error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    // Report errors to our system, but don't pass the context directly
    // from here as it might be during build
    ErrorReporter.reportError(null, details.exception, details.stack);

    // Instead, log the error and let the app handle UI notification
    // at a safe time
  };
}

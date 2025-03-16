import 'package:flutter/material.dart';
import 'utils/error_reporter.dart';

void initializeErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    ErrorReporter.reportError(details.exception, details.stack);
  };
}

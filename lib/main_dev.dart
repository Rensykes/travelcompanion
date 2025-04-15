import 'package:flutter/material.dart';
import 'main.dart' as app;

void main() async {
  // Set development environment
  app.isDebugMode = true;

  // Initialize app
  WidgetsFlutterBinding.ensureInitialized();

  // Start the app - background tasks will be initialized
  // after the battery optimization dialog is shown
  app.main();
}

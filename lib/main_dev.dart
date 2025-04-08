import 'package:flutter/material.dart';
import 'package:trackie/core/scheduler/background_task.dart';

import 'main.dart' as app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Workmanager for background tasks
  initializeWorkmanager(isInDebugMode: true);

  app.main();
}

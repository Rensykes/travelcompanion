import 'package:flutter/material.dart';

import 'core/scheduler/background_task.dart';
import 'main.dart' as app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Production-specific initialization
  // For example, configuring crash reporting
  initializeWorkmanager(isInDebugMode: false);

  app.main();
}

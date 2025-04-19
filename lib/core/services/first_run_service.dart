import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackie/application/services/permission_service.dart';

/// Service for handling first-run application tasks
///
/// This service manages tasks that should only run the first time
/// a user opens the app, such as:
/// - Prompting for battery optimization exemption
/// - Showing onboarding screens or welcome dialogs
/// - Setting initial preferences
class FirstRunService {
  static const String _firstRunKey = 'app_first_run_completed';
  static const String _batteryOptPromptShownKey = 'battery_opt_prompt_shown';

  final PermissionService _permissionService;

  /// Constructor that takes a PermissionService dependency
  FirstRunService(this._permissionService);

  /// Checks if this is the first run of the application
  ///
  /// Returns true if this is the first time running the app
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstRunKey) ?? false);
  }

  /// Marks the first run as completed
  Future<void> markFirstRunCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstRunKey, true);
    log(
      "First run marked as completed",
      name: 'FirstRunService',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  /// Checks if the battery optimization prompt has been shown
  Future<bool> hasBatteryOptPromptBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_batteryOptPromptShownKey) ?? false;
  }

  /// Marks that the battery optimization prompt has been shown
  Future<void> markBatteryOptPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_batteryOptPromptShownKey, true);
    log(
      "Battery optimization prompt marked as shown",
      name: 'FirstRunService',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  /// Shows a dialog prompting the user to disable battery optimization
  ///
  /// Returns true if the user agrees to proceed, false otherwise
  Future<bool> showBatteryOptimizationDialog(BuildContext context) async {
    // Safety check for the prompt
    if (await hasBatteryOptPromptBeenShown()) {
      return true; // Skip showing dialog if already shown previously
    }

    // Safety check for valid context
    if (!context.mounted) {
      log("Context is not mounted, skipping battery optimization dialog");
      return false;
    }

    // Mark that we've shown this prompt (do this first to prevent duplicate dialogs)
    await markBatteryOptPromptShown();

    try {
      bool result = false;

      // For additional safety, check Navigator availability
      if (Navigator.canPop(context)) {
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Improve Background Tracking'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.battery_alert,
                    size: 48,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'For the app to reliably track your location in the background, '
                    'please disable battery optimization for this app.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'This will allow the app to work properly even when not actively used.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    result = false;
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    result = true;
                    Navigator.of(dialogContext).pop();

                    // Request battery optimization exemption
                    await _permissionService.requestIgnoreBatteryOptimization();
                  },
                  child: const Text('Disable Battery Optimization'),
                ),
              ],
            );
          },
        );
      } else {
        // If we can't show a dialog, just request directly
        result = await _permissionService.requestIgnoreBatteryOptimization();
      }

      return result;
    } catch (e) {
      log("Error showing battery optimization dialog: $e");
      // In case of error, fall back to direct permission request
      return await _permissionService.requestIgnoreBatteryOptimization();
    }
  }

  /// Performs all first-run tasks and checks
  ///
  /// This is the main method to call when initializing the app
  Future<void> performFirstRunTasks(BuildContext context) async {
    try {
      final isFirstAppRun = await isFirstRun();

      if (isFirstAppRun) {
        log(
          "Performing first run tasks",
          name: 'FirstRunService',
          level: 0, // INFO
          time: DateTime.now(),
        );

        // Request battery optimization exemption
        if (context.mounted) {
          await showBatteryOptimizationDialog(context);
        }

        // Mark first run as completed
        await markFirstRunCompleted();
      }
    } catch (e) {
      log("Error performing first run tasks: $e");
    }
  }
}

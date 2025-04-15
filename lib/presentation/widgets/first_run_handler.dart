import 'package:flutter/material.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/core/services/first_run_service.dart';
import 'package:trackie/core/app_initialization.dart';

/// Widget that handles showing first-run prompts and dialogs
///
/// This widget wraps around your app and ensures that first-run
/// dialogs are shown at the appropriate time, after the app UI
/// has been built and is visible to the user.
class FirstRunHandler extends StatefulWidget {
  final Widget child;
  final bool isDebugMode;

  const FirstRunHandler({
    super.key,
    required this.child,
    required this.isDebugMode,
  });

  @override
  State<FirstRunHandler> createState() => _FirstRunHandlerState();
}

class _FirstRunHandlerState extends State<FirstRunHandler> {
  final FirstRunService _firstRunService = getIt<FirstRunService>();
  bool _checkedFirstRun = false;
  bool _initializedBackgroundTasks = false;

  @override
  void initState() {
    super.initState();
    // Use a delay to ensure the Navigator is fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkFirstRun();
      }
    });
  }

  /// Checks if this is the first run and shows relevant prompts
  Future<void> _checkFirstRun() async {
    if (!_checkedFirstRun && mounted) {
      setState(() {
        _checkedFirstRun = true;
      });

      try {
        // Perform first run tasks (show battery optimization dialog if needed)
        await _firstRunService.performFirstRunTasks(context);

        // Initialize background tasks after first run tasks are completed
        _initializeBackgroundTasks();
      } catch (e) {
        debugPrint('Error in FirstRunHandler: $e');
        // Still try to initialize background tasks even if there was an error
        _initializeBackgroundTasks();
      }
    }
  }

  /// Initialize background tasks if not already done
  void _initializeBackgroundTasks() {
    if (!_initializedBackgroundTasks) {
      setState(() {
        _initializedBackgroundTasks = true;
      });

      // Initialize background tasks with the appropriate debug mode
      AppInitialization.initializeBackgroundTasks(
        isDebugMode: widget.isDebugMode,
      );

      debugPrint(
          'Background tasks initialized with debug mode: ${widget.isDebugMode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

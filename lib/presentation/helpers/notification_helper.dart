import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class NotificationHelper {
  static Flushbar? _currentFlushbar;
  static bool _isDismissing = false;
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Set the navigator key for global context access
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Show a notification with the given title, message, and type
  /// If context is not provided, will attempt to use the global navigator key's context
  static void showNotification(
    BuildContext? context,
    String title,
    String message,
    ContentType type, {
    bool useFlushbar = true,
    Duration? duration,
    bool isDismissible = true,
  }) {
    // If we're already dismissing a notification, delay showing the new one
    if (_isDismissing) {
      // Schedule the notification to show after dismissal is complete
      Future.delayed(const Duration(milliseconds: 300), () {
        showNotification(
          context,
          title,
          message,
          type,
          useFlushbar: useFlushbar,
          duration: duration,
          isDismissible: isDismissible,
        );
      });
      return;
    }

    // Dismiss any existing notification first
    _dismissCurrentNotification();

    // Get the effective context - either the provided one or from the navigator key
    BuildContext? effectiveContext;

    // First try the provided context if it's valid
    if (context != null && context.mounted) {
      effectiveContext = context;
    }
    // Fall back to the navigator key's context
    else if (_navigatorKey?.currentContext != null) {
      effectiveContext = _navigatorKey!.currentContext!;
    }

    // If no valid context is available, log an error and return
    if (effectiveContext == null) {
      debugPrint(
          'Warning: No valid context available for showing notification');
      return;
    }

    // Show the appropriate notification type
    if (useFlushbar) {
      // Use Future.microtask to ensure we're not in the middle of a build cycle
      Future.microtask(() {
        if (effectiveContext != null) {
          _showFlushbar(effectiveContext, title, message, type,
              duration: duration, isDismissible: isDismissible);
        }
      });
    } else {
      _showSnackbar(effectiveContext, title, message, type,
          isDismissible: isDismissible);
    }
  }

  /// Dismiss any currently showing notification
  static void _dismissCurrentNotification() {
    if (_currentFlushbar != null && !_isDismissing) {
      _isDismissing = true;

      try {
        _currentFlushbar?.dismiss().then((_) {
          _currentFlushbar = null;
          _isDismissing = false;
        }).catchError((error) {
          // Handle any errors during dismissal
          debugPrint('Error dismissing Flushbar: $error');
          _currentFlushbar = null;
          _isDismissing = false;
        });
      } catch (e) {
        // Reset state if an exception occurs
        debugPrint('Exception while dismissing Flushbar: $e');
        _currentFlushbar = null;
        _isDismissing = false;
      }
    }
  }

  /// Show a Flushbar notification
  static void _showFlushbar(
    BuildContext context,
    String title,
    String message,
    ContentType type, {
    Duration? duration,
    bool isDismissible = true,
  }) {
    Flushbar? flushbar;
    final effectiveDuration =
        duration ?? Duration(seconds: isDismissible ? 5 : 3);

    // Create the appropriate Flushbar based on notification type and add a dismiss button
    switch (type) {
      case ContentType.success:
        flushbar = _createFeedbackFlushbar(
          context: context,
          title: title,
          message: message,
          duration: effectiveDuration,
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
          isDismissible: isDismissible,
        );
        break;
      case ContentType.warning:
        flushbar = _createFeedbackFlushbar(
          context: context,
          title: title,
          message: message,
          duration: effectiveDuration,
          backgroundColor: Colors.orange,
          icon: Icons.warning,
          isDismissible: isDismissible,
        );
        break;
      case ContentType.help:
        flushbar = _createFeedbackFlushbar(
          context: context,
          title: title,
          message: message,
          duration: effectiveDuration,
          backgroundColor: Colors.blue,
          icon: Icons.info,
          isDismissible: isDismissible,
        );
        break;
      case ContentType.failure:
        flushbar = _createFeedbackFlushbar(
          context: context,
          title: title,
          message: message,
          duration: effectiveDuration,
          backgroundColor: Colors.red,
          icon: Icons.error,
          isDismissible: isDismissible,
        );
        break;
    }

    // Show the Flushbar if it was created
    if (flushbar != null) {
      _currentFlushbar = flushbar;

      try {
        // Show the flushbar
        flushbar.show(context).then((_) {
          if (_currentFlushbar == flushbar) {
            _currentFlushbar = null;
          }
        }).catchError((error) {
          debugPrint('Error showing Flushbar: $error');
          if (_currentFlushbar == flushbar) {
            _currentFlushbar = null;
          }
        });
      } catch (e) {
        debugPrint('Exception while showing Flushbar: $e');
        _currentFlushbar = null;
      }
    }
  }

  /// Create a customized Flushbar with the appropriate styling
  static Flushbar _createFeedbackFlushbar({
    required BuildContext context,
    required String title,
    required String message,
    required Duration duration,
    required Color backgroundColor,
    required IconData icon,
    bool isDismissible = true,
  }) {
    return Flushbar(
      title: title,
      message: message,
      duration: duration,
      backgroundColor: backgroundColor,
      icon: Icon(icon, color: Colors.white),
      leftBarIndicatorColor: backgroundColor.withOpacity(0.7),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      isDismissible: isDismissible,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      mainButton: isDismissible
          ? TextButton(
              onPressed: () => _dismissCurrentNotification(),
              child: const Text(
                'DISMISS',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  /// Show a SnackBar notification
  static void _showSnackbar(
    BuildContext context,
    String title,
    String message,
    ContentType type, {
    bool isDismissible = true,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.fixed,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
      action: isDismissible
          ? SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            )
          : null,
      duration: isDismissible
          ? const Duration(seconds: 5)
          : const Duration(seconds: 3),
    );

    try {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } catch (e) {
      debugPrint('Error showing SnackBar: $e');
    }
  }
}

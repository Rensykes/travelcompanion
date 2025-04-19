import 'dart:developer';

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
      log('Warning: No valid context available for showing notification');
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
          log('Error dismissing Flushbar: $error');
          _currentFlushbar = null;
          _isDismissing = false;
        });
      } catch (e) {
        // Reset state if an exception occurs
        log('Exception while dismissing Flushbar: $e');
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
    // Dismiss any existing Flushbar first
    _dismissCurrentNotification();

    _currentFlushbar = Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title: title,
      message: message,
      isDismissible: isDismissible,
      duration: duration ?? Duration(seconds: isDismissible ? 5 : 3),
      backgroundColor: _getBackgroundColor(type),
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.all(8),
      icon: _getIconForType(type),
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
      onStatusChanged: (status) {
        if (status == FlushbarStatus.DISMISSED) {
          _currentFlushbar = null;
        }
      },
    )..show(context);
  }

  /// Get the appropriate icon for the notification type
  static Icon _getIconForType(ContentType type) {
    switch (type) {
      case ContentType.success:
        return const Icon(Icons.check_circle, color: Colors.white);
      case ContentType.failure:
        return const Icon(Icons.error, color: Colors.white);
      case ContentType.help:
        return const Icon(Icons.info, color: Colors.white);
      case ContentType.warning:
        return const Icon(Icons.warning, color: Colors.white);
      default:
        return const Icon(Icons.notifications, color: Colors.white);
    }
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
      log('Error showing SnackBar: $e');
    }
  }

  static Color _getBackgroundColor(ContentType type) {
    switch (type) {
      case ContentType.success:
        return Colors.green;
      case ContentType.failure:
        return Colors.red;
      case ContentType.help:
        return Colors.blue;
      case ContentType.warning:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

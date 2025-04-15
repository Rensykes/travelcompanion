import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:trackie/core/utils/flushbar_helper.dart';

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
  }) {
    // If we're already dismissing a notification, delay showing the new one
    if (_isDismissing) {
      // Schedule the notification to show after dismissal is complete
      Future.delayed(const Duration(milliseconds: 300), () {
        showNotification(context, title, message, type,
            useFlushbar: useFlushbar);
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
        _showFlushbar(title, message, type);
      });
    } else {
      _showSnackbar(effectiveContext, title, message, type);
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

  /// Show a Flushbar notification using the navigator key's context
  static void _showFlushbar(
    String title,
    String message,
    ContentType type,
  ) {
    // Check if we have a valid navigator key
    if (_navigatorKey == null || _navigatorKey!.currentContext == null) {
      debugPrint('Cannot show Flushbar: No valid navigator key or context');
      return;
    }

    // Get the context from the navigator key
    final navigatorContext = _navigatorKey!.currentContext!;
    Flushbar? flushbar;

    // Create the appropriate Flushbar based on notification type
    switch (type) {
      case ContentType.success:
        flushbar = CustomFlushbar.createSuccess(
          context: navigatorContext,
          title: title,
          message: message,
        );
        break;
      case ContentType.warning:
        flushbar = CustomFlushbar.createWarning(
          context: navigatorContext,
          title: title,
          message: message,
        );
        break;
      case ContentType.help:
        flushbar = CustomFlushbar.createInfo(
          context: navigatorContext,
          title: title,
          message: message,
        );
        break;
      case ContentType.failure:
        flushbar = CustomFlushbar.createError(
          context: navigatorContext,
          title: title,
          message: message,
        );
        break;
    }

    // Show the Flushbar if it was created
    if (flushbar != null) {
      _currentFlushbar = flushbar;

      try {
        // Use the navigator context directly
        flushbar.show(navigatorContext).then((_) {
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

  /// Show a SnackBar notification
  static void _showSnackbar(
    BuildContext context,
    String title,
    String message,
    ContentType type,
  ) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.fixed,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
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

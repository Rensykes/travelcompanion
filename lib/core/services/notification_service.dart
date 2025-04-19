import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

/// A simple notification data model
class NotificationData {
  final String title;
  final String message;
  final ContentType type;

  const NotificationData({
    required this.title,
    required this.message,
    required this.type,
  });
}

/// Service to handle pending notifications across navigation
class NotificationService {
  NotificationData? _pendingNotification;

  /// Set a notification to be shown on the next screen
  void setPendingNotification(String title, String message, ContentType type) {
    _pendingNotification = NotificationData(
      title: title,
      message: message,
      type: type,
    );
    log('Set pending notification: $title - $message');
  }

  /// Get and clear the pending notification
  NotificationData? consumePendingNotification() {
    final notification = _pendingNotification;
    if (notification != null) {
      log('Consuming notification: ${notification.title}');
    }
    _pendingNotification = null;
    return notification;
  }

  /// Check if there's a pending notification
  bool hasPendingNotification() {
    return _pendingNotification != null;
  }
}

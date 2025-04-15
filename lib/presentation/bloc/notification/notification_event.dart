import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

/// Event to show a notification immediately
class ShowNotification extends NotificationEvent {
  final String title;
  final String message;
  final ContentType type;
  final bool useFlushbar;

  const ShowNotification({
    required this.title,
    required this.message,
    required this.type,
    this.useFlushbar = true,
  });

  @override
  List<Object> get props => [title, message, type, useFlushbar];
}

/// Event to queue a notification to be shown when context is available
class QueueNotification extends NotificationEvent {
  final String title;
  final String message;
  final ContentType type;
  final bool useFlushbar;

  const QueueNotification({
    required this.title,
    required this.message,
    required this.type,
    this.useFlushbar = true,
  });

  @override
  List<Object> get props => [title, message, type, useFlushbar];
}

/// Event to check and process any queued notifications
class CheckQueuedNotifications extends NotificationEvent {
  const CheckQueuedNotifications();
}

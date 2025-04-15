import 'dart:collection';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/notification/notification_event.dart';
import 'package:trackie/presentation/bloc/notification/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  // Queue for storing notifications that should be shown when context is available
  final Queue<Map<String, dynamic>> _notificationQueue = Queue();

  NotificationBloc() : super(NotificationInitial()) {
    on<ShowNotification>(_onShowNotification);
    on<QueueNotification>(_onQueueNotification);
    on<CheckQueuedNotifications>(_onCheckQueuedNotifications);
  }

  void _onShowNotification(
    ShowNotification event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationShown(
      title: event.title,
      message: event.message,
      type: event.type,
      useFlushbar: event.useFlushbar,
    ));
  }

  void _onQueueNotification(
    QueueNotification event,
    Emitter<NotificationState> emit,
  ) {
    log('Queuing notification: ${event.title}');
    _notificationQueue.add({
      'title': event.title,
      'message': event.message,
      'type': event.type,
      'useFlushbar': event.useFlushbar,
    });
  }

  void _onCheckQueuedNotifications(
    CheckQueuedNotifications event,
    Emitter<NotificationState> emit,
  ) {
    if (_notificationQueue.isNotEmpty) {
      log('Found ${_notificationQueue.length} queued notifications');

      final notification = _notificationQueue.removeFirst();

      emit(NotificationShown(
        title: notification['title'],
        message: notification['message'],
        type: notification['type'],
        useFlushbar: notification['useFlushbar'],
      ));
    }
  }
}

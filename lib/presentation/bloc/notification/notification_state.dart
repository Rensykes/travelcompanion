import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationShown extends NotificationState {
  final String title;
  final String message;
  final dynamic type;
  final bool useFlushbar;

  NotificationShown({
    required this.title,
    required this.message,
    this.type,
    this.useFlushbar = true,
  });

  @override
  List<Object?> get props => [title, message, type, useFlushbar];
}

/// State indicating that a notification is queued to be shown after navigation
class NotificationQueued extends NotificationState {
  final String title;
  final String message;
  final dynamic type;
  final bool useFlushbar;

  NotificationQueued({
    required this.title,
    required this.message,
    this.type,
    this.useFlushbar = true,
  });

  @override
  List<Object?> get props => [title, message, type, useFlushbar];
}

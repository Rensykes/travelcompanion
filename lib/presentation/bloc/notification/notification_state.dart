import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationShown extends NotificationState {
  final String title;
  final String message;
  final ContentType type;
  final bool useFlushbar;

  NotificationShown({
    required this.title,
    required this.message,
    required this.type,
    required this.useFlushbar,
  });
}

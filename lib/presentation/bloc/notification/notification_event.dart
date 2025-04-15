import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

abstract class NotificationEvent {}

class ShowNotification extends NotificationEvent {
  final String title;
  final String message;
  final ContentType type;
  final bool useFlushbar;

  ShowNotification({
    required this.title,
    required this.message,
    required this.type,
    this.useFlushbar = true,
  });
}

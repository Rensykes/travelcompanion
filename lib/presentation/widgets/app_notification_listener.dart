import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/notification/notification_bloc.dart';
import 'package:trackie/presentation/bloc/notification/notification_state.dart';
import 'package:trackie/presentation/bloc/notification/notification_event.dart';
import 'package:trackie/presentation/helpers/notification_helper.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:developer' as dev;

class AppNotificationListener extends StatefulWidget {
  final Widget child;

  const AppNotificationListener({
    super.key,
    required this.child,
  });

  @override
  State<AppNotificationListener> createState() =>
      _AppNotificationListenerState();
}

class _AppNotificationListenerState extends State<AppNotificationListener> {
  @override
  void initState() {
    super.initState();

    // Check for queued notifications after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final notificationBloc = context.read<NotificationBloc>();
        // Trigger check for any queued notifications
        dev.log('Checking for queued notifications on app start or navigation');
        notificationBloc.add(CheckQueuedNotifications());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) => current is NotificationShown,
      listener: (context, state) {
        if (state is NotificationShown) {
          dev.log('Showing notification: ${state.title}');

          // Convert dynamic type to ContentType if needed
          ContentType contentType;
          if (state.type is ContentType) {
            contentType = state.type as ContentType;
          } else {
            // Default to help type if not specified correctly
            contentType = ContentType.help;
          }

          NotificationHelper.showNotification(
            context,
            state.title,
            state.message,
            contentType,
            useFlushbar: state.useFlushbar,
            isDismissible: true, // Always allow dismissing notifications
          );
        }
      },
      child: widget.child,
    );
  }
}

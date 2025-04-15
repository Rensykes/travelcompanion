import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/notification/notification_bloc.dart';
import 'package:trackie/presentation/bloc/notification/notification_state.dart';
import 'package:trackie/presentation/helpers/notification_helper.dart';

class AppNotificationListener extends StatelessWidget {
  final Widget child;

  const AppNotificationListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) => current is NotificationShown,
      listener: (context, state) {
        if (state is NotificationShown) {
          NotificationHelper.showNotification(
            context,
            state.title,
            state.message,
            state.type,
            useFlushbar: state.useFlushbar,
          );
        }
      },
      child: child,
    );
  }
}

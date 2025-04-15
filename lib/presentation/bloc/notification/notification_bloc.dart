import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/notification/notification_event.dart';
import 'package:trackie/presentation/bloc/notification/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<ShowNotification>((event, emit) {
      emit(NotificationShown(
        title: event.title,
        message: event.message,
        type: event.type,
        useFlushbar: event.useFlushbar,
      ));
    });
  }
}

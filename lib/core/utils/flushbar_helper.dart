import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class CustomFlushbar {
  static Flushbar createSuccess({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
  }) {
    return Flushbar(
      title: title,
      message: message,
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.green,
      icon: const Icon(
        Icons.check_circle,
        color: Colors.white,
      ),
      leftBarIndicatorColor: Colors.green[300],
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    );
  }

  static Flushbar createError({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
  }) {
    return Flushbar(
      title: title,
      message: message,
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.red,
      icon: const Icon(
        Icons.error,
        color: Colors.white,
      ),
      leftBarIndicatorColor: Colors.red[300],
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    );
  }

  static Flushbar createInfo({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
  }) {
    return Flushbar(
      title: title,
      message: message,
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.blue,
      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
      leftBarIndicatorColor: Colors.blue[300],
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    );
  }

  static Flushbar createWarning({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
  }) {
    return Flushbar(
      title: title,
      message: message,
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.orange,
      icon: const Icon(
        Icons.warning,
        color: Colors.white,
      ),
      leftBarIndicatorColor: Colors.orange[300],
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    );
  }

  static Flushbar createLoading({
    required BuildContext context,
    String? title,
    required String message,
    Duration? duration,
  }) {
    return Flushbar(
      title: title,
      message: message,
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.blue,
      icon: const Icon(
        Icons.hourglass_empty,
        color: Colors.white,
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blue[300],
      leftBarIndicatorColor: Colors.blue[300],
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trackie/presentation/screens/error_screen.dart';

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ErrorScreen(error: error),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trackie/presentation/screens/error_screen.dart';
import 'package:trackie/core/utils/app_themes.dart';

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: ErrorScreen(error: error),
    );
  }
}

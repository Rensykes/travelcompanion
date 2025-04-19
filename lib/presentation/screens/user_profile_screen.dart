import 'package:flutter/material.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/presentation/bloc/user_info/user_info_cubit.dart';
import 'package:trackie/presentation/widgets/user_info_display.dart';
import 'package:trackie/presentation/widgets/gradient_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen to display and edit user profile information
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<UserInfoCubit>()
        ..loadUserInfo(), // Load user info when screen opens
      child: GradientScaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: UserInfoDisplay(),
          ),
        ),
      ),
    );
  }
}

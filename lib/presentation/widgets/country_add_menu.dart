import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:trackie/core/constants/route_constants.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_cubit.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';

class CountryAddMenu extends StatelessWidget {
  const CountryAddMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a key to control the CircularMenu state
    final menuKey = GlobalKey<CircularMenuState>();

    return CircularMenu(
      key: menuKey,
      alignment: Alignment.bottomRight,
      toggleButtonColor: Theme.of(context).colorScheme.primary,
      toggleButtonIconColor: Theme.of(context).colorScheme.onPrimary,
      toggleButtonSize: 24.0,
      toggleButtonMargin: 5.0,
      radius: 50.0,
      items: [
        CircularMenuItem(
          icon: Icons.phone_android,
          color: Theme.of(context).colorScheme.primary,
          iconSize: 18,
          onTap: () {
            // Reverse the animation to close the menu
            menuKey.currentState?.reverseAnimation();
            // Then handle the action
            _handleCarrierOption(context);
          },
        ),
        CircularMenuItem(
          icon: Icons.plus_one,
          color: Theme.of(context).colorScheme.secondary,
          iconSize: 18,
          onTap: () {
            // Reverse the animation to close the menu
            menuKey.currentState?.reverseAnimation();
            // Then handle the action
            _handleManualOption(context);
          },
        ),
      ],
    );
  }

  void _handleCarrierOption(BuildContext context) {
    final appShellCubit = context.read<AppShellCubit>();

    appShellCubit.addCountry((title, message, contentType) {
      SnackBarHelper.showSnackBar(
        context,
        title,
        message,
        ContentType.success,
      );
    });
  }

  void _handleManualOption(BuildContext context) {
    context.push(RouteConstants.manualAddFullPath);
  }
}

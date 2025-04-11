import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:trackie/core/constants/route_constants.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_cubit.dart';

class CountryAddMenu extends StatelessWidget {
  const CountryAddMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularMenu(
      alignment: Alignment.bottomRight,
      toggleButtonColor: Theme.of(context).colorScheme.primary,
      toggleButtonIconColor: Theme.of(context).colorScheme.onPrimary,
      toggleButtonSize: 48.0,
      toggleButtonMargin: 25.0,
      radius: 100.0,
      items: [
        CircularMenuItem(
          icon: Icons.phone_android,
          color: Theme.of(context).colorScheme.primary,
          iconSize: 18,
          onTap: () {
            _handleCarrierOption(context);
          },
        ),
        CircularMenuItem(
          icon: Icons.edit_location,
          color: Theme.of(context).colorScheme.secondary,
          iconSize: 18,
          onTap: () {
            _handleManualOption(context);
          },
        ),
      ],
    );
  }

  void _handleCarrierOption(BuildContext context) {
    final appShellCubit = context.read<AppShellCubit>();

    appShellCubit.addCountry((title, message, contentType) {
      _showCustomNotification(context, title, message, contentType);
    });
  }

  void _showCustomNotification(
    BuildContext context,
    String title,
    String message,
    ContentType contentType,
  ) {
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.1,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: AwesomeSnackbarContent(
              title: title,
              message: message,
              contentType: contentType,
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }

  void _handleManualOption(BuildContext context) {
    context.push(RouteConstants.manualAddFullPath);
  }
}

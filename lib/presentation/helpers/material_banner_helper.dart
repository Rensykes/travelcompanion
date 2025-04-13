import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class MaterialBannerHelper {
  static void showMaterialBanner(
    BuildContext context,
    String title,
    String message,
    ContentType type,
  ) {
    final materialBanner = MaterialBanner(
      forceActionsBelow: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);
  }
}

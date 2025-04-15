import 'package:flutter/material.dart';
import 'package:trackie/core/utils/app_themes.dart';
import 'package:trackie/core/utils/theme_manager.dart';

/// A widget that provides a consistent gradient background for the application.
///
/// This can be wrapped around any widget to provide a gradient background.
/// Use it with Scaffold to create a gradient background for screens.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool useDarkGradient;

  /// Creates a gradient background.
  ///
  /// [child] is the widget to display over the gradient.
  /// [useDarkGradient] determines whether to use the dark theme gradient.
  const GradientBackground({
    super.key,
    required this.child,
    this.useDarkGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Use appropriate colors based on theme
    final usesDarkMode = useDarkGradient || isDarkMode;

    // Get gradient colors from ThemeManager
    final gradientColors =
        ThemeManager.getGradientColors(isDarkMode: usesDarkMode);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: child,
    );
  }
}

/// A Scaffold with a gradient background.
///
/// This widget combines a Scaffold with the GradientBackground to
/// provide a consistent gradient background for screens.
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool useDarkGradient;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Creates a scaffold with a gradient background.
  ///
  /// The [appBar], [body], [floatingActionButton], and [bottomNavigationBar]
  /// parameters are forwarded to the underlying [Scaffold].
  const GradientScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.useDarkGradient = false,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Get the brightness from the current theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use the dark gradient if in dark mode or if explicitly requested
    final usesDarkGradient = useDarkGradient || isDarkMode;

    // Get appropriate theme colors
    final currentTheme =
        usesDarkGradient ? AppThemes.darkTheme : AppThemes.lightTheme;

    return GradientBackground(
      useDarkGradient: usesDarkGradient,
      child: Scaffold(
        // Make the scaffold background transparent to show the gradient
        backgroundColor: Colors.transparent,
        // Make the app bar transparent to show the gradient
        appBar: appBar != null
            ? _transparentAppBar(
                appBar!,
                titleColor: currentTheme.appBarTheme.titleTextStyle?.color,
                iconColor: currentTheme.iconTheme.color,
              )
            : null,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }

  /// Makes an AppBar transparent to allow the gradient to show through
  PreferredSizeWidget _transparentAppBar(
    PreferredSizeWidget appBar, {
    Color? titleColor,
    Color? iconColor,
  }) {
    if (appBar is AppBar) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: appBar.elevation,
        scrolledUnderElevation: appBar.scrolledUnderElevation,
        title: appBar.title,
        foregroundColor: titleColor ?? Colors.white,
        iconTheme: IconThemeData(color: iconColor ?? Colors.white),
        actions: appBar.actions,
        leading: appBar.leading,
        centerTitle: appBar.centerTitle,
        bottom: appBar.bottom,
      );
    }
    return appBar;
  }
}

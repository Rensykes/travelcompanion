import 'package:flutter/material.dart';
import 'package:trackie/core/utils/app_themes.dart';
import 'package:trackie/presentation/widgets/theme_card.dart';

/// Helper class that provides methods to create standardized themed cards
/// throughout the application.
///
/// This centralizes the styling and configuration of cards to maintain
/// consistency and a modern look across the app.
class CardHelper {
  /// Creates a standard themed card with solid background for content sections.
  ///
  /// Use this for general content sections throughout the app.
  static Widget standardCard({
    required Widget child,
    double elevation = 3,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return ThemeCard(
      elevation: elevation,
      padding: padding ?? const EdgeInsets.all(16.0),
      onTap: onTap,
      child: child,
    );
  }

  /// Creates a highlighted card style.
  ///
  /// Use this for important sections or calls to action.
  static Widget highlightCard({
    required Widget child,
    double elevation = 4,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return ThemeCard(
      elevation: elevation,
      borderWidth: 0.7,
      borderColor: AppThemes.primaryGreen.withOpacity(0.3),
      padding: padding ?? const EdgeInsets.all(16.0),
      onTap: onTap,
      child: child,
    );
  }

  /// Creates a dark-themed card.
  ///
  /// Use this when you need contrast against the background.
  static Widget darkCard({
    required Widget child,
    double elevation = 3,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return ThemeCard(
      useDarkVariant: true,
      elevation: elevation,
      padding: padding ?? const EdgeInsets.all(16.0),
      onTap: onTap,
      child: child,
    );
  }

  /// Creates a card specifically styled for list tiles.
  ///
  /// Use this when creating cards that contain lists of items.
  static Widget listCard({
    required List<Widget> children,
    double elevation = 3,
    VoidCallback? onTap,
  }) {
    return ThemeCard(
      elevation: elevation,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Creates a card specifically for statistic displays.
  ///
  /// Use this for numerical data or metrics.
  static Widget statCard({
    required Widget child,
    double elevation = 3,
    VoidCallback? onTap,
  }) {
    return ThemeCard(
      elevation: elevation,
      borderRadius: 18.0,
      borderWidth: 0.7,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      onTap: onTap,
      child: child,
    );
  }

  /// Creates a subtle card with minimal styling.
  ///
  /// Use this for secondary information or when you want a more subdued card.
  static Widget subtleCard({
    required Widget child,
    double elevation = 1,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return ThemeCard(
      elevation: elevation,
      borderWidth: 0.3,
      padding: padding ?? const EdgeInsets.all(16.0),
      onTap: onTap,
      child: child,
    );
  }

  /// Creates a colorful card with a custom tint.
  ///
  /// Use this to create cards with a specific color accent.
  static Widget coloredCard({
    required Widget child,
    required Color color,
    double elevation = 3,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    final lightColor = Color.lerp(color, Colors.white, 0.85);

    return ThemeCard(
      elevation: elevation,
      backgroundColor: lightColor,
      borderColor: color.withOpacity(0.4),
      padding: padding ?? const EdgeInsets.all(16.0),
      onTap: onTap,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trackie/core/utils/app_themes.dart';

/// A styled card with solid background that follows the app theme.
///
/// This widget provides an elegant card with proper elevation,
/// colors and borders that match the app's theme.
class ThemeCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final double elevation;
  final bool useDarkVariant;

  /// Creates a styled card with solid background.
  ///
  /// [child] is the widget to display inside the card.
  /// [borderRadius] determines the roundness of the card's corners.
  /// [padding] is the internal padding of the card.
  /// [backgroundColor] the card's background color (defaults to theme appropriate).
  /// [borderColor] defines the color of the card border.
  /// [borderWidth] determines the width of the border.
  /// [onTap] is the callback when the card is tapped.
  /// [elevation] controls the shadow beneath the card.
  /// [useDarkVariant] force the dark style regardless of theme.
  const ThemeCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.5,
    this.onTap,
    this.elevation = 3,
    this.useDarkVariant = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark || useDarkVariant;

    // Determine background color based on theme
    final bgColor = backgroundColor ??
        (isDarkMode
            ? const Color(0xFF1F2820)
                .withAlpha(100) // Dark green-gray for dark theme
            : Colors.white);

    // Border color based on theme
    final border = borderColor ??
        (isDarkMode
            ? AppThemes.darkTheme.primaryColor.withOpacity(0.3)
            : AppThemes.primaryGreen.withOpacity(0.15));

    // Shadow color based on theme
    final shadow = isDarkMode
        ? Colors.black.withOpacity(0.4)
        : Colors.black.withOpacity(0.1);

    return Material(
      color: bgColor,
      elevation: elevation,
      shadowColor: shadow,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: isDarkMode
            ? AppThemes.darkTheme.primaryColor.withOpacity(0.1)
            : AppThemes.primaryGreen.withOpacity(0.1),
        highlightColor: isDarkMode
            ? Colors.white.withOpacity(0.03)
            : AppThemes.primaryGreen.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: border,
              width: borderWidth,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A list tile for use with ThemeCard.
class ThemeListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;
  final bool useDarkVariant;

  /// Creates a styled list tile for use in cards.
  const ThemeListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
    this.useDarkVariant = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark || useDarkVariant;

    // Text colors based on theme
    final titleColor =
        isDarkMode ? Colors.white.withOpacity(0.95) : AppThemes.darkGreen;

    final subtitleColor = isDarkMode
        ? Colors.white.withOpacity(0.7)
        : AppThemes.darkGreen.withOpacity(0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      splashColor: isDarkMode
          ? AppThemes.darkTheme.primaryColor.withOpacity(0.1)
          : AppThemes.primaryGreen.withOpacity(0.1),
      highlightColor: isDarkMode
          ? Colors.white.withOpacity(0.03)
          : AppThemes.primaryGreen.withOpacity(0.05),
      child: Padding(
        padding: contentPadding,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                      child: title!,
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

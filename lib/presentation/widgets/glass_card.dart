import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:trackie/core/utils/theme_manager.dart';

/// A card with a premium, semi-transparent glass effect.
///
/// This widget provides a modern glass-like effect with blur and elegant
/// borders to create depth and contrast. Works beautifully against gradient
/// backgrounds to create a high-end UI look.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blurAmount;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final double opacity;
  final VoidCallback? onTap;
  final double elevation;

  /// Creates a semi-transparent card with a premium glass effect.
  ///
  /// [child] is the widget to display inside the card.
  /// [borderRadius] determines the roundness of the card's corners.
  /// [padding] is the internal padding of the card.
  /// [blurAmount] controls the intensity of the blur effect.
  /// [color] is the base color of the card (typically white with opacity).
  /// [borderColor] defines the color of the card border.
  /// [borderWidth] determines the width of the border.
  /// [opacity] sets the overall opacity of the card.
  /// [onTap] is the callback when the card is tapped.
  /// [elevation] controls the shadow beneath the card.
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.blurAmount = 6.0,
    this.color = Colors.white,
    this.borderColor,
    this.borderWidth = 0.5,
    this.opacity = 0.2,
    this.onTap,
    this.elevation = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use ThemeManager to get appropriate colors
    final actualColor = color == Colors.white
        ? ThemeManager.getGlassCardBaseColor(isDarkMode: isDarkMode)
        : color;

    final actualBorderColor = borderColor ??
        ThemeManager.getGlassCardBorderColor(isDarkMode: isDarkMode);

    final shadowColor = ThemeManager.getShadowColor(isDarkMode: isDarkMode);

    return Material(
      color: Colors.transparent,
      elevation: elevation,
      shadowColor: shadowColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: Colors.transparent,
        highlightColor: Colors.white.withOpacity(0.05),
        hoverColor: Colors.white.withOpacity(0.05),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurAmount,
              sigmaY: blurAmount,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: actualColor.withOpacity(opacity),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: actualBorderColor,
                  width: borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    actualColor.withOpacity(opacity + 0.05),
                    actualColor.withOpacity(opacity - 0.05),
                  ],
                ),
              ),
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A list tile with a premium glass effect, designed to be used inside a [GlassCard].
class GlassListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  /// Creates a list tile with a premium glass-like appearance.
  ///
  /// This widget is designed to be used within a [GlassCard] to create
  /// consistent semi-transparent list items with an elegant look.
  const GlassListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        ThemeManager.getGlassCardTextColor(isDarkMode: isDarkMode);
    final subtitleColor =
        ThemeManager.getGlassCardSubtitleColor(isDarkMode: isDarkMode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      splashColor: ThemeManager.getOverlayColor(
        isDarkMode: isDarkMode,
        opacity: 0.1,
      ),
      highlightColor: ThemeManager.getOverlayColor(
        isDarkMode: isDarkMode,
        opacity: 0.05,
      ),
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
                        letterSpacing: 0.2,
                        color: textColor,
                      ),
                      child: title!,
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 0.1,
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

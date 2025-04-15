import 'package:flutter/material.dart';
import 'package:trackie/core/utils/app_themes.dart';

/// Manager class for handling theme integration with custom widgets.
///
/// This class provides utility methods to get appropriate colors and styles
/// for custom widgets based on the current theme.
class ThemeManager {
  /// Get primary gradient colors for the current theme.
  ///
  /// Returns a list of colors appropriate for gradients based on whether
  /// it's dark mode or light mode.
  static List<Color> getGradientColors({required bool isDarkMode}) {
    if (isDarkMode) {
      // Dark theme gradient - dark greens
      return [
        const Color(0xFF1A2E1C), // Very dark green
        AppThemes.darkTheme.primaryColor,
        const Color(0xFF2D4F3A), // Slightly lighter green
      ];
    } else {
      // Light theme gradient - greens
      return [
        AppThemes.primaryGreen, // Forest Green
        const Color(0xFF729762), // Medium green
        AppThemes.lightGreen, // Light green background
      ];
    }
  }

  /// Get glass card base color based on the current theme.
  ///
  /// This provides appropriate base colors for glass cards to ensure they
  /// look good on top of theme-specific backgrounds.
  static Color getGlassCardBaseColor({required bool isDarkMode}) {
    return isDarkMode
        ? Colors.white.withOpacity(0.07)
        : Colors.white.withOpacity(0.7);
  }

  /// Get glass card border color based on the current theme.
  ///
  /// Returns an appropriate border color for glass cards.
  static Color getGlassCardBorderColor({required bool isDarkMode}) {
    return isDarkMode
        ? Colors.white.withOpacity(0.25)
        : AppThemes.primaryGreen.withOpacity(0.3);
  }

  /// Get appropriate text color for text on glass cards.
  ///
  /// Ensures text has proper contrast on the glass card background.
  static Color getGlassCardTextColor({required bool isDarkMode}) {
    return isDarkMode
        ? Colors.white.withOpacity(0.95)
        : AppThemes.darkGreen; // Better contrast on light backgrounds
  }

  /// Get appropriate subtitled text color for text on glass cards.
  ///
  /// For secondary text that needs less emphasis but still good contrast.
  static Color getGlassCardSubtitleColor({required bool isDarkMode}) {
    return isDarkMode
        ? Colors.white.withOpacity(0.7)
        : AppThemes.darkGreen.withOpacity(0.75);
  }

  /// Get an appropriate color with opacity for overlays.
  ///
  /// Useful for creating overlays and subtle color effects.
  static Color getOverlayColor({
    required bool isDarkMode,
    required double opacity,
  }) {
    final baseColor =
        isDarkMode ? AppThemes.darkTheme.primaryColor : AppThemes.primaryGreen;

    return baseColor.withOpacity(opacity);
  }

  /// Get appropriate shadow color based on theme.
  ///
  /// Provides shadow colors that look good with the current theme.
  static Color getShadowColor({required bool isDarkMode}) {
    return isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.2);
  }

  /// Get accent color for highlighting important elements.
  ///
  /// Used for items that need to stand out with good contrast.
  static Color getAccentColor({required bool isDarkMode}) {
    return isDarkMode
        ? AppThemes.darkTheme.colorScheme.secondary // Medium green
        : AppThemes.contrastBrown; // Brown for contrast on light theme
  }
}

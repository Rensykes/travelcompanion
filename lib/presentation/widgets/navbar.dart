import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trackie/core/utils/app_themes.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    const double gap = 0;
    const padding = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1F2820)
                .withOpacity(0.8) // Semi-transparent dark green
            : Colors.white.withOpacity(0.6), // Semi-transparent white
        // No border radius for a flat design
        borderRadius: BorderRadius.zero,
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? AppThemes.darkTheme.primaryColor.withOpacity(0.2)
                : AppThemes.primaryGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            spreadRadius: -5,
            blurRadius: 10,
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 3),
        child: GNav(
          padding: padding,
          gap: gap,
          tabMargin: const EdgeInsets.symmetric(horizontal: 1),
          tabBorderRadius: 15,
          tabActiveBorder: Border.all(color: Colors.transparent, width: 1),
          duration: const Duration(milliseconds: 200),
          activeColor: Theme.of(context).primaryColor,
          iconSize: 22, // Slightly larger icons
          tabBackgroundColor: Colors.transparent, // Transparent tab background
          hoverColor: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : AppThemes.primaryGreen.withOpacity(0.05),
          tabs: [
            // Dashboard
            GButton(
              iconActiveColor: AppThemes.primaryGreen,
              iconColor: Colors.grey,
              textColor: AppThemes.primaryGreen,
              backgroundColor: AppThemes.primaryGreen.withOpacity(0.15),
              icon: LineIcons.home,
            ),
            // Travel History Timeline
            GButton(
              iconActiveColor: AppThemes.primaryGreen,
              iconColor: Colors.grey,
              textColor: AppThemes.primaryGreen,
              backgroundColor: AppThemes.primaryGreen.withOpacity(0.15),
              icon: LineIcons.history,
            ),
            // Calendar
            GButton(
              iconActiveColor: AppThemes.primaryGreen,
              iconColor: Colors.grey,
              textColor: AppThemes.primaryGreen,
              backgroundColor: AppThemes.primaryGreen.withOpacity(0.15),
              icon: LineIcons.calendar,
            ),
            // Countries List
            GButton(
              iconActiveColor: AppThemes.primaryGreen,
              iconColor: Colors.grey,
              textColor: AppThemes.primaryGreen,
              backgroundColor: AppThemes.primaryGreen.withOpacity(0.15),
              icon: LineIcons.globe,
            ),
            // Logs
            GButton(
              iconActiveColor: AppThemes.primaryGreen,
              iconColor: Colors.grey,
              textColor: AppThemes.primaryGreen,
              backgroundColor: AppThemes.primaryGreen.withOpacity(0.15),
              icon: LineIcons.alternateListAlt,
            ),
            // Settings
            GButton(
              iconActiveColor: AppThemes.primaryGreen,
              iconColor: Colors.grey,
              textColor: AppThemes.primaryGreen,
              backgroundColor: AppThemes.primaryGreen.withOpacity(0.15),
              icon: LineIcons.cog,
            ),
          ],
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}

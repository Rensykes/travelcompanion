import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class CustomGoogleNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const CustomGoogleNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    const double gap = 10;
    const padding = EdgeInsets.symmetric(horizontal: 18, vertical: 12);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          boxShadow: [
            BoxShadow(
              spreadRadius: -10,
              blurRadius: 60,
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 25),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
          child: GNav(
            tabs: [
              GButton(
                gap: gap,
                iconActiveColor: Colors.blue,
                iconColor: Colors.grey,
                textColor: Colors.blue,
                backgroundColor: Colors.blue.withValues(alpha: .2),
                iconSize: 24,
                padding: padding,
                icon: LineIcons.alternateListAlt,
                text: 'Entries',
              ),
              GButton(
                gap: gap,
                iconActiveColor: Colors.purple,
                iconColor: Colors.grey,
                textColor: Colors.purple,
                backgroundColor: Colors.purple.withValues(alpha: .2),
                iconSize: 24,
                padding: padding,
                icon: LineIcons.history,
                text: 'Logs',
              ),
              GButton(
                gap: gap,
                iconActiveColor: Colors.teal,
                iconColor: Colors.grey,
                textColor: Colors.teal,
                backgroundColor: Colors.teal.withValues(alpha: .2),
                iconSize: 24,
                padding: padding,
                icon: LineIcons.cog,
                text: 'Settings',
              ),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}

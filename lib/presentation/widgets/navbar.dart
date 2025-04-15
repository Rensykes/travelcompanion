import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

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

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            spreadRadius: -10,
            blurRadius: 60,
            color: Colors.black.withValues(alpha: .4),
            offset: const Offset(0, 25),
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
          tabs: [
            // Dashboard
            GButton(
              iconActiveColor: Colors.blue,
              iconColor: Colors.grey,
              textColor: Colors.blue,
              backgroundColor: Colors.blue.withValues(alpha: .2),
              iconSize: 20,
              icon: LineIcons.home,
              //text: 'Home',
            ),
            // Travel History Timeline
            GButton(
              iconActiveColor: Colors.green,
              iconColor: Colors.grey,
              textColor: Colors.green,
              backgroundColor: Colors.green.withValues(alpha: .2),
              iconSize: 20,
              icon: LineIcons.history,
              //text: 'Timeline',
            ),
            // Calendar
            GButton(
              iconActiveColor: Colors.purple,
              iconColor: Colors.grey,
              textColor: Colors.purple,
              backgroundColor: Colors.purple.withValues(alpha: .2),
              iconSize: 20,
              icon: LineIcons.calendar,
              //text: 'Calendar',
            ),
            // Countries List
            GButton(
              iconActiveColor: Colors.orange,
              iconColor: Colors.grey,
              textColor: Colors.orange,
              backgroundColor: Colors.orange.withValues(alpha: .2),
              iconSize: 20,
              icon: LineIcons.globe,
              //text: 'Countries',
            ),
            // Logs
            GButton(
              iconActiveColor: Colors.indigo,
              iconColor: Colors.grey,
              textColor: Colors.indigo,
              backgroundColor: Colors.indigo.withValues(alpha: .2),
              iconSize: 20,
              icon: LineIcons.alternateListAlt,
              //text: 'Logs',
            ),
            // Settings
            GButton(
              iconActiveColor: Colors.teal,
              iconColor: Colors.grey,
              textColor: Colors.teal,
              backgroundColor: Colors.teal.withValues(alpha: .2),
              iconSize: 20,
              icon: LineIcons.cog,
              //text: 'Settings',
            ),
          ],
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}

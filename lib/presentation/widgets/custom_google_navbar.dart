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
    const double gap = 0;
    const padding = EdgeInsets.symmetric(horizontal: 15, vertical: 8);

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            spreadRadius: -10,
            blurRadius: 60,
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
        child: GNav(
          padding: padding,
          gap: gap,
          tabs: [
            GButton(
              iconActiveColor: Colors.blue,
              iconColor: Colors.grey,
              textColor: Colors.blue,
              backgroundColor: Colors.blue.withOpacity(.2),
              iconSize: 24,
              icon: LineIcons.alternateListAlt,
              //text: 'Entries',
            ),
            GButton(
              iconActiveColor: Colors.purple,
              iconColor: Colors.grey,
              textColor: Colors.purple,
              backgroundColor: Colors.purple.withOpacity(.2),
              iconSize: 24,
              icon: LineIcons.calculator,
              //text: 'Calendar',
            ),
            GButton(
              iconActiveColor: Colors.indigo,
              iconColor: Colors.grey,
              textColor: Colors.indigo,
              backgroundColor: Colors.indigo.withOpacity(.2),
              iconSize: 24,
              icon: LineIcons.history,
              //text: 'Logs',
            ),
            GButton(
              iconActiveColor: Colors.teal,
              iconColor: Colors.grey,
              textColor: Colors.teal,
              backgroundColor: Colors.teal.withOpacity(.2),
              iconSize: 24,
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

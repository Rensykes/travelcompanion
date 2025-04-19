import 'package:flutter/material.dart';
import 'package:tab_container/tab_container.dart';

class StatsTabContainer extends StatelessWidget {
  final List<Widget> tabs;
  final List<Widget> children;

  const StatsTabContainer({
    super.key,
    required this.tabs,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TabContainer(
      color: colorScheme.surfaceContainerHighest.withAlpha(100),
      tabEdge: TabEdge.top,
      curve: Curves.easeInOut,
      tabExtent: 50,
      childPadding: const EdgeInsets.all(16.0),
      selectedTextStyle: TextStyle(
        color: colorScheme.onPrimary,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      unselectedTextStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.7),
        fontSize: 14.0,
      ),
      tabs: tabs,
      children: children,
    );
  }
}

class StatsTabItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const StatsTabItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Use the secondary color which is more visible in dark theme
    // or fallback to onSurface with high opacity for better visibility
    final tabColor = colorScheme.secondary.computeLuminance() > 0.4
        ? colorScheme.secondary
        : colorScheme.onSurface.withOpacity(0.9);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: tabColor),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: tabColor,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';

class EmptyStatsView extends StatelessWidget {
  final String message;
  final String submessage;
  final IconData icon;
  final VoidCallback? onRefresh;

  const EmptyStatsView({
    super.key,
    required this.message,
    this.submessage = 'Add travel data to see interesting visualizations here',
    this.icon = Icons.analytics_outlined,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) {
          onRefresh!();
        } else {
          DataRefreshUtil.refreshAllData(context: context);
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 6),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    submessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (onRefresh != null) {
                      onRefresh!();
                    } else {
                      DataRefreshUtil.refreshAllData(context: context);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

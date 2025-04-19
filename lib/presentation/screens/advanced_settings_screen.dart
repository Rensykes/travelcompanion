import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackie/application/services/permission_service.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/core/app_initialization.dart';
import 'package:trackie/main.dart' show isDebugMode;
import 'package:permission_handler/permission_handler.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:trackie/presentation/helpers/notification_helper.dart';
import 'package:trackie/core/services/task_status_service.dart';
import 'package:trackie/presentation/widgets/gradient_background.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  AdvancedSettingsScreenState createState() => AdvancedSettingsScreenState();
}

class AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> with WidgetsBindingObserver {
  bool _showErrorLogs = true;
  bool _expandTaskStats = false;

  // Permission states
  bool _batteryOptimizationDisabled = false;
  bool _locationPermissionGranted = false;
  bool _backgroundLocationPermissionGranted = false;

  // Task status properties
  String _lastExecution = 'Never';
  int _executionCount = 0;
  int _successCount = 0;
  int _failureCount = 0;
  String _successRate = 'N/A';
  TaskHealthStatus _taskHealth = TaskHealthStatus.unknown;

  // Services
  final PermissionService _permissionService = getIt<PermissionService>();
  final TaskStatusService _taskStatusService = getIt<TaskStatusService>();

  @override
  void initState() {
    super.initState();
    // Register the observer for lifecycle events
    WidgetsBinding.instance.addObserver(this);
    
    // Load data when the screen is initialized
    _loadPreferences();
    _checkPermissionStatus();
    _loadTaskStatus();
  }
  
  @override
  void dispose() {
    // Remove the observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _refreshAllData();
    }
  }
  
  // Add this method to refresh all data at once
  Future<void> _refreshAllData() async {
    await _checkPermissionStatus();
    await _loadTaskStatus();
    
    if (mounted) {
      setState(() {
        // Force UI refresh
      });
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change (e.g., when returning to this screen)
    _refreshAllData();
  }

  // Load task status information
  Future<void> _loadTaskStatus() async {
    try {
      // This will now trigger synchronization from the file if needed
      final stats = await _taskStatusService.getTaskStatistics();
      final health = await _taskStatusService.checkTaskHealth();
      final lastExecution =
          await _taskStatusService.getFormattedTimeSinceLastExecution();

      setState(() {
        _lastExecution = lastExecution;
        _executionCount = stats['executionCount'] ?? 0;
        _successCount = stats['successCount'] ?? 0;
        _failureCount = stats['failureCount'] ?? 0;
        _successRate = stats['successRate'] ?? 'N/A';
        _taskHealth = health;
      });
      
      // Log task stats loaded to help with debugging
      log(
        'Task stats loaded - Executions: $_executionCount, Success: $_successCount, Failure: $_failureCount',
        name: 'AdvancedSettingsScreen',
        level: 0, // INFO
        time: DateTime.now(),
      );
    } catch (e) {
      log('Error loading task status: $e');
    }
  }

  // Reset task statistics
  Future<void> _resetTaskStatistics() async {
    // Use the implementation without notification
    await _resetTaskStatisticsWithoutNotification();
    
    // Then show a notification
    NotificationHelper.showNotification(
      context,
      "Statistics Reset",
      "Background task statistics have been reset",
      ContentType.help,
    );
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showErrorLogs = prefs.getBool('showErrorLogs') ?? true;
    });
    log(
      '🔄 Loaded showErrorLogs preference: $_showErrorLogs',
      name: 'AdvancedSettingsScreen',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  // Save the error logs preference
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showErrorLogs', _showErrorLogs);
    log(
      '💾 Saved showErrorLogs preference: $_showErrorLogs',
      name: 'AdvancedSettingsScreen',
      level: 1, // SUCCESS
      time: DateTime.now(),
    );
  }

  // Handle error logs toggle
  void _toggleErrorLogs(bool value) {
    setState(() {
      _showErrorLogs = value;
    });
    _savePreferences();
    log(
      '🔀 Toggled showErrorLogs to: $_showErrorLogs',
      name: 'AdvancedSettingsScreen',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  // Check the status of relevant permissions
  Future<void> _checkPermissionStatus() async {
    final batteryOptStatus = await Permission.ignoreBatteryOptimizations.status;
    final locationStatus = await Permission.locationWhenInUse.status;
    final backgroundLocationStatus = await Permission.locationAlways.status;

    setState(() {
      _batteryOptimizationDisabled = batteryOptStatus.isGranted;
      _locationPermissionGranted = locationStatus.isGranted;
      _backgroundLocationPermissionGranted = backgroundLocationStatus.isGranted;
    });

    log(
      'Permissions status: Battery Opt = ${batteryOptStatus.name}, '
      'Location = ${locationStatus.name}, '
      'Background Location = ${backgroundLocationStatus.name}',
      name: 'AdvancedSettingsScreen',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  // Request battery optimization exemption
  Future<void> _requestBatteryOptimization() async {
    final result = await _permissionService.requestIgnoreBatteryOptimization();
    await _checkPermissionStatus();

    log(
      'Battery optimization exemption request result: $result',
      name: 'AdvancedSettingsScreen',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    await _checkPermissionStatus();

    log(
      'Location permission request result: ${status.name}',
      name: 'AdvancedSettingsScreen',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  // Request background location permission
  Future<void> _requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    await _checkPermissionStatus();

    log(
      'Background location permission request result: ${status.name}',
      name: 'AdvancedSettingsScreen',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  // Reinitialize the workmanager
  Future<void> _reinitializeWorkmanager() async {
    // Initialize the background tasks
    AppInitialization.initializeBackgroundTasks(isDebugMode: isDebugMode);

    // Log the action
    log(
      'Workmanager reinitialized manually from Advanced Settings',
      name: 'AdvancedSettingsScreen',
      level: 0, // INFO
      time: DateTime.now(),
    );

    // Reset task statistics but don't show notification from there
    await _resetTaskStatisticsWithoutNotification();
    
    // Explicitly refresh the status UI
    await _loadTaskStatus();
    
    // Make sure UI state is updated
    if (mounted) {
      setState(() {
        // Force UI refresh
      });
    }
    
    // Show a single notification for both actions
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        NotificationHelper.showNotification(
          context,
          "Tasks Reinitialized",
          "Background tasks have been successfully reinitialized and statistics reset",
          ContentType.help,
        );
      }
    });
  }
  
  // Reset task statistics without showing a notification
  Future<void> _resetTaskStatisticsWithoutNotification() async {
    try {
      // Reset the statistics in the service
      await _taskStatusService.resetTaskStatistics();
      
      // Reload task status data to refresh the UI
      final stats = await _taskStatusService.getTaskStatistics();
      final health = await _taskStatusService.checkTaskHealth();
      final lastExecution = await _taskStatusService.getFormattedTimeSinceLastExecution();
      
      // Update the state with the refreshed data
      if (mounted) {
        setState(() {
          _lastExecution = lastExecution;
          _executionCount = stats['executionCount'] ?? 0;
          _successCount = stats['successCount'] ?? 0;
          _failureCount = stats['failureCount'] ?? 0; 
          _successRate = stats['successRate'] ?? 'N/A';
          _taskHealth = health;
        });
      }
      
      log(
        'Task statistics reset successfully',
        name: 'AdvancedSettingsScreen',
        level: 0, // INFO
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        'Error resetting task statistics: $e',
        name: 'AdvancedSettingsScreen',
        error: e,
        level: 900, // ERROR
        time: DateTime.now(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Advanced Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Permissions Section
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Permissions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildPermissionCard(
                  title: 'Battery Optimization',
                  subtitle:
                      'Allow the app to run in the background without battery restrictions',
                  status: _batteryOptimizationDisabled ? 'Disabled' : 'Enabled',
                  isGranted: _batteryOptimizationDisabled,
                  onRequest: _requestBatteryOptimization,
                ),
                _buildPermissionCard(
                  title: 'Location Permission',
                  subtitle: 'Allow the app to access your location',
                  status: _locationPermissionGranted ? 'Granted' : 'Denied',
                  isGranted: _locationPermissionGranted,
                  onRequest: _requestLocationPermission,
                ),
                _buildPermissionCard(
                  title: 'Background Location',
                  subtitle:
                      'Allow the app to access your location even when the app is closed',
                  status: _backgroundLocationPermissionGranted
                      ? 'Granted'
                      : 'Denied',
                  isGranted: _backgroundLocationPermissionGranted,
                  onRequest: _requestBackgroundLocationPermission,
                ),

                // Background Task Status Section
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Background Task Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with health status and expand/collapse button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Task Health',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _taskHealth.statusColor
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _taskHealth.statusIcon,
                                        size: 16,
                                        color: _taskHealth.statusColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _taskHealth.statusText,
                                        style: TextStyle(
                                          color: _taskHealth.statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Add refresh button
                                IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    _loadTaskStatus();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Refreshed task status'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  tooltip: 'Refresh status',
                                ),
                                // Expand/collapse button
                                IconButton(
                                  icon: Icon(
                                    _expandTaskStats
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _expandTaskStats = !_expandTaskStats;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Only show details if expanded
                        if (_expandTaskStats) ...[
                          const Divider(),
                          _buildStatusRow('Last execution', _lastExecution),
                          _buildStatusRow(
                              'Total executions', '$_executionCount'),
                          _buildStatusRow(
                              'Successful executions', '$_successCount'),
                          _buildStatusRow(
                              'Failed executions', '$_failureCount'),
                          _buildStatusRow('Success rate', _successRate),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: OutlinedButton(
                                    onPressed: _resetTaskStatistics,
                                    child: const Text(
                                      'Reset Stats',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _reinitializeWorkmanager,
                                  child: const Text(
                                    'Reinitialize',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Logs Settings Section
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Logs Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Show Error Logs'),
                  subtitle: const Text(
                    'Show logs with status "error" in the logs list',
                  ),
                  value: _showErrorLogs,
                  onChanged: (bool value) => _toggleErrorLogs(value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build a status row in the task status card
  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper method to build a permission card
  Widget _buildPermissionCard({
    required String title,
    required String subtitle,
    required String status,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isGranted ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isGranted
                          ? Colors.green.shade900
                          : Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRequest,
              child: Text(isGranted ? 'Verify Permission' : 'Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to track and monitor background task execution
class TaskStatusService {
  // Keys for SharedPreferences
  static const String _lastExecutionKey = 'background_task_last_execution';
  static const String _executionCountKey = 'background_task_execution_count';
  static const String _successCountKey = 'background_task_success_count';
  static const String _failureCountKey = 'background_task_failure_count';

  // Thresholds for determining task health
  static const Duration _healthyThreshold = Duration(minutes: 20);
  static const Duration _warningThreshold = Duration(minutes: 60);

  /// Records a successful task execution
  Future<void> recordTaskExecution({required bool success}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store current time as last execution timestamp
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastExecutionKey, now);

      // Increment execution count
      final executionCount = prefs.getInt(_executionCountKey) ?? 0;
      await prefs.setInt(_executionCountKey, executionCount + 1);

      // Update success/failure counts
      if (success) {
        final successCount = prefs.getInt(_successCountKey) ?? 0;
        await prefs.setInt(_successCountKey, successCount + 1);
      } else {
        final failureCount = prefs.getInt(_failureCountKey) ?? 0;
        await prefs.setInt(_failureCountKey, failureCount + 1);
      }

      log(
        "Background task execution recorded (success: $success)",
        name: 'TaskStatusService',
        level: success ? 0 : 900,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "Failed to record task execution: $e",
        name: 'TaskStatusService',
        level: 1000,
        time: DateTime.now(),
      );
    }
  }

  /// Resets all task statistics
  Future<void> resetTaskStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastExecutionKey);
      await prefs.remove(_executionCountKey);
      await prefs.remove(_successCountKey);
      await prefs.remove(_failureCountKey);

      log(
        "Task statistics reset",
        name: 'TaskStatusService',
        level: 0,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "Failed to reset task statistics: $e",
        name: 'TaskStatusService',
        level: 1000,
        time: DateTime.now(),
      );
    }
  }

  /// Gets the timestamp of the last task execution
  Future<DateTime?> getLastExecutionTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastExecutionKey);

      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      log(
        "Failed to get last execution time: $e",
        name: 'TaskStatusService',
        level: 1000,
        time: DateTime.now(),
      );
      return null;
    }
  }

  /// Gets the current count of task executions
  Future<int> getExecutionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_executionCountKey) ?? 0;
    } catch (e) {
      log(
        "Failed to get execution count: $e",
        name: 'TaskStatusService',
        level: 1000,
        time: DateTime.now(),
      );
      return 0;
    }
  }

  /// Gets statistics about task executions
  Future<Map<String, dynamic>> getTaskStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastExecution = prefs.getInt(_lastExecutionKey);
      final executionCount = prefs.getInt(_executionCountKey) ?? 0;
      final successCount = prefs.getInt(_successCountKey) ?? 0;
      final failureCount = prefs.getInt(_failureCountKey) ?? 0;

      DateTime? lastExecutionTime;
      Duration? timeSinceLastExecution;

      if (lastExecution != null) {
        lastExecutionTime = DateTime.fromMillisecondsSinceEpoch(lastExecution);
        timeSinceLastExecution = DateTime.now().difference(lastExecutionTime);
      }

      return {
        'lastExecutionTime': lastExecutionTime,
        'timeSinceLastExecution': timeSinceLastExecution,
        'executionCount': executionCount,
        'successCount': successCount,
        'failureCount': failureCount,
        'successRate': executionCount > 0
            ? (successCount / executionCount * 100).toStringAsFixed(1) + '%'
            : 'N/A',
      };
    } catch (e) {
      log(
        "Failed to get task statistics: $e",
        name: 'TaskStatusService',
        level: 1000,
        time: DateTime.now(),
      );
      return {
        'error': 'Failed to get statistics',
      };
    }
  }

  /// Checks the health status of the background tasks
  Future<TaskHealthStatus> checkTaskHealth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastExecution = prefs.getInt(_lastExecutionKey);

      // If no execution has been recorded yet
      if (lastExecution == null) {
        return TaskHealthStatus.unknown;
      }

      final lastExecutionTime =
          DateTime.fromMillisecondsSinceEpoch(lastExecution);
      final timeSinceLastExecution =
          DateTime.now().difference(lastExecutionTime);

      // Determine health status based on time since last execution
      if (timeSinceLastExecution < _healthyThreshold) {
        return TaskHealthStatus.healthy;
      } else if (timeSinceLastExecution < _warningThreshold) {
        return TaskHealthStatus.warning;
      } else {
        return TaskHealthStatus.critical;
      }
    } catch (e) {
      log(
        "Failed to check task health: $e",
        name: 'TaskStatusService',
        level: 1000,
        time: DateTime.now(),
      );
      return TaskHealthStatus.unknown;
    }
  }

  /// Gets a formatted string of time since last execution
  Future<String> getFormattedTimeSinceLastExecution() async {
    final lastExecution = await getLastExecutionTime();

    if (lastExecution == null) {
      return 'Never executed';
    }

    final duration = DateTime.now().difference(lastExecution);

    if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

/// Enum representing the health status of background tasks
enum TaskHealthStatus {
  healthy,
  warning,
  critical,
  unknown;

  Color get statusColor {
    switch (this) {
      case TaskHealthStatus.healthy:
        return Colors.green;
      case TaskHealthStatus.warning:
        return Colors.orange;
      case TaskHealthStatus.critical:
        return Colors.red;
      case TaskHealthStatus.unknown:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (this) {
      case TaskHealthStatus.healthy:
        return 'Healthy';
      case TaskHealthStatus.warning:
        return 'Warning';
      case TaskHealthStatus.critical:
        return 'Critical';
      case TaskHealthStatus.unknown:
        return 'Unknown';
    }
  }

  IconData get statusIcon {
    switch (this) {
      case TaskHealthStatus.healthy:
        return Icons.check_circle;
      case TaskHealthStatus.warning:
        return Icons.warning;
      case TaskHealthStatus.critical:
        return Icons.error;
      case TaskHealthStatus.unknown:
        return Icons.help;
    }
  }
}

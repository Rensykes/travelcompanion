import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_cubit.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_state.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/core/constants/route_constants.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';

class QuickLogsAddScreen extends StatefulWidget {
  const QuickLogsAddScreen({super.key});

  @override
  State<QuickLogsAddScreen> createState() => _QuickLogsAddScreenState();
}

class _QuickLogsAddScreenState extends State<QuickLogsAddScreen> {
  void refreshAllData() {
    DataRefreshUtil.refreshAllData(context: context);
  }

  Future<void> _showInternetConnectionAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Internet Connection Required'),
          content: const SingleChildScrollView(
            child: Text(
              'This feature requires an internet connection to work properly.',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  context.pop();
                }
              },
            ),
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  context.pop();
                }
                context.push(RouteConstants.manualAddFullPath);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Location Log'),
      ),
      body: BlocProvider.value(
        value: context.read<AppShellCubit>(),
        child: BlocBuilder<AppShellCubit, AppShellState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _buildSection(
                      'Carrier Detection',
                      'Automatically detect your location based on carrier information',
                      Icons.network_cell,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: state.isFetchingLocation
                          ? null
                          : () async {
                              await context.read<AppShellCubit>().addCountry(
                                (title, message, status) {
                                  SnackBarHelper.showSnackBar(
                                    context,
                                    title,
                                    message,
                                    status,
                                  );
                                },
                              );

                              if (context.mounted) {
                                refreshAllData();
                                // Navigate back to home after successful operation
                                context.go(RouteConstants.homeFullPath);
                              }
                            },
                      icon: state.isFetchingLocation
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_location),
                      label: const Text('Add Current Location'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildSection(
                      'Manual Entry',
                      'Manually enter your location and travel details',
                      Icons.edit_location_alt,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showInternetConnectionAlert(context);
                      },
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Add Manually'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

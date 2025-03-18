import 'package:flutter/material.dart';
import 'package:trackie/services/location_service.dart';
import 'package:trackie/utils/location_permission_manager.dart'; // The file we just created
import 'package:trackie/screens/home_screen.dart';

class PermissionCheckScreen extends StatefulWidget {
  final bool isDarkMode;
  final bool useSystemTheme;
  final Function(bool, bool) onThemeChanged;

  const PermissionCheckScreen({
    Key? key,
    required this.isDarkMode,
    required this.useSystemTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _PermissionCheckScreenState createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {
  bool _isCheckingPermission = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    bool hasPermission = await LocationPermissionManager.hasAlwaysLocationPermission();
    
    if (hasPermission) {
      // Permission already granted, go to home screen
      _navigateToHome();
    } else {
      // Request permission
      bool granted = await LocationPermissionManager.checkAndRequestPermission(context);
      
      if (granted) {
        _navigateToHome();
      } else {
        setState(() {
          _permissionDenied = true;
          _isCheckingPermission = false;
        });
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          isDarkMode: widget.isDarkMode,
          useSystemTheme: widget.useSystemTheme,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking location permissions...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Required'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Location Permission Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Trackie needs "Always" location permission to track countries you visit even when the app is closed.\n\n'
              'Without this permission, the app won\'t be able to function properly.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await LocationService.openLocationSettings();
                // After returning from settings, check if permission was granted
                bool hasPermission = await LocationPermissionManager.hasAlwaysLocationPermission();
                if (hasPermission) {
                  _navigateToHome();
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Open Settings',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _navigateToHome();
              },
              child: const Text(
                'Continue Without Permission',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: The app won\'t be able to track your visits in the background',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
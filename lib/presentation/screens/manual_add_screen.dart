import 'package:flutter/material.dart';

class ManualAddScreen extends StatelessWidget {
  const ManualAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Location Entry'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Manual location entry form coming soon...',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

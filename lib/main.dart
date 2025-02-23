import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/country_adapter.dart';
import 'screens/home_screen.dart';  // Import the new main screen

// Only initializes Hive and runs the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(CountryVisitAdapter().typeId)) {
      Hive.registerAdapter(CountryVisitAdapter());
    }
    
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    // Add proper error handling/reporting here
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // Navigates to the main screen
    );
  }
}

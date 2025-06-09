import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/services/hive_service.dart';
import 'package:habit_tracker_app/theme/app_theme.dart';
import 'package:habit_tracker_app/screens/home_screen.dart'; // Import HomeScreen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.instance.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode
      home: const HomeScreen(), // Use HomeScreen here
      debugShowCheckedModeBanner: false,
    );
  }
}

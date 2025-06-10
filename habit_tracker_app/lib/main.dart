import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/services/hive_service.dart';
import 'package:habit_tracker_app/services/widget_service.dart';
import 'package:habit_tracker_app/theme/app_theme.dart';
import 'package:habit_tracker_app/screens/home_screen.dart';
import 'package:habit_tracker_app/providers/theme_provider.dart'; // Import theme provider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // It's important Hive is initialized before ThemeModeNotifier tries to use it.
  // HiveService.init() also initializes Hive itself.
  // We also need to ensure the settings box for theme is opened.
  // For simplicity, ThemeModeNotifier opens it. Alternatively, open it in HiveService.init()
  await HiveService.instance.init();
  
  // Initialize widget service
  try {
    await WidgetService.registerBackgroundUpdate();
  } catch (e) {
    print('Widget service initialization failed: $e');
  }
  
  // If ThemeModeNotifier's _init needs the box to be open before its constructor is called
  // (which it does if it accesses it synchronously or early), then opening the box
  // _themeModeBoxName here or in HiveService.instance.init() is safer.
  // Let's assume ThemeModeNotifier's lazy opening is sufficient for now.

  runApp(const ProviderScope(child: MyApp()));
}

// Change MyApp to ConsumerWidget to access themeModeProvider
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef
    final themeMode = ref.watch(themeModeProvider); // Watch the theme mode

    return MaterialApp(
      title: 'Habit Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Use themeMode from provider
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

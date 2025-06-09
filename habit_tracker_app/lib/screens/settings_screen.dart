import 'dart:convert'; // For utf8
import 'dart:io'; // For File
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/providers/theme_provider.dart';
import 'package:habit_tracker_app/services/hive_service.dart'; // Import HiveService
import 'package:habit_tracker_app/providers/habit_provider.dart'; // To refresh habits list
import 'package:path_provider/path_provider.dart'; // For temporary file storage for sharing
import 'package:share_plus/share_plus.dart'; // For sharing files

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final String jsonString = await HiveService.instance.exportDataToJson();

      // Create a temporary file to share
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/habits_export.json';
      final file = File(filePath);
      await file.writeAsString(jsonString, flush: true);

      // Use share_plus to share the file
      final result = await Share.shareXFiles(
          [XFile(filePath)],
          text: 'My Habit Tracker Data',
          subject: 'Habit Tracker Export' // Subject for email
      );

      if (result.status == ShareResultStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data exported successfully and shared!')),
          );
      } else if (result.status == ShareResultStatus.dismissed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sharing dismissed.')),
          );
      }


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: $e')),
      );
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();

        final bool success = await HiveService.instance.importDataFromJson(jsonString);

        if (success) {
          // Refresh the habits list in the UI
          await ref.read(habitsProvider.notifier).loadHabits();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data imported successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to import data. Invalid file format or content.')),
          );
        }
      } else {
        // User canceled the picker
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import canceled.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing data: $e')),
      );
    }
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final confirmClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to delete ALL habit data? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Clear Data', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmClear == true) {
      try {
        await HiveService.instance.clearAllData();
        await ref.read(habitsProvider.notifier).loadHabits(); // Refresh UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All habit data cleared.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing data: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Appearance'),
            subtitle: Text(currentThemeMode == ThemeMode.light ? 'Light Mode' : (currentThemeMode == ThemeMode.dark ? 'Dark Mode' : 'System Default')),
            leading: Icon(currentThemeMode == ThemeMode.light ? Icons.wb_sunny : (currentThemeMode == ThemeMode.dark ? Icons.nightlight_round : Icons.brightness_auto)),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Choose Theme'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RadioListTile<ThemeMode>(
                          title: const Text('Light Mode'), value: ThemeMode.light, groupValue: currentThemeMode,
                          onChanged: (ThemeMode? value) {
                            if (value != null) { ref.read(themeModeProvider.notifier).setThemeMode(value); Navigator.of(context).pop();}
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('Dark Mode'), value: ThemeMode.dark, groupValue: currentThemeMode,
                          onChanged: (ThemeMode? value) {
                            if (value != null) { ref.read(themeModeProvider.notifier).setThemeMode(value); Navigator.of(context).pop(); }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('System Default'), value: ThemeMode.system, groupValue: currentThemeMode,
                          onChanged: (ThemeMode? value) {
                            if (value != null) { ref.read(themeModeProvider.notifier).setThemeMode(value); Navigator.of(context).pop(); }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Export Data'),
            leading: const Icon(Icons.upload_file),
            onTap: () => _exportData(context, ref),
          ),
          ListTile(
            title: const Text('Import Data'),
            leading: const Icon(Icons.download),
            onTap: () => _importData(context, ref),
          ),
          const Divider(),
          ListTile(
            title: Text('Clear All Data', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            onTap: () => _clearAllData(context, ref),
          ),
        ],
      ),
    );
  }
}

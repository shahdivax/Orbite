import 'dart:convert'; // For jsonEncode and jsonDecode
// For File operations (will need path_provider for path)
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:path_provider/path_provider.dart'; // For getting documents directory

class HiveService {
  static const String _habitBoxName = 'habits';
  // Keep the settings box name consistent with ThemeProvider
  static const String _settingsBoxName = 'settings';

  HiveService._privateConstructor();
  static final HiveService _instance = HiveService._privateConstructor();
  static HiveService get instance => _instance;

  Box<Habit>? _habitBox;
  Box? _settingsBox; // Generic box for settings

  Future<void> init() async {
    // Ensure Hive is initialized (this path might vary based on platform)
    // For mobile, getApplicationDocumentsDirectory is needed.
    // For web, Hive.initFlutter() is enough.
    if (!Hive.isBoxOpen(_habitBoxName)) { // Check to prevent re-initialization issues
        try {
            final appDocumentDir = await getApplicationDocumentsDirectory();
            Hive.init(appDocumentDir.path);
        } catch (e) {
            print("Error getting document directory for Hive init: $e. Using Hive.initFlutter().");
            await Hive.initFlutter();
        }
    }

    // Register Adapters
    if (!Hive.isAdapterRegistered(HabitAdapter().typeId)) {
      Hive.registerAdapter(HabitAdapter());
    }
    if (!Hive.isAdapterRegistered(FrequencyTypeAdapter().typeId)) {
      Hive.registerAdapter(FrequencyTypeAdapter());
    }

    // Open boxes
    _habitBox = await Hive.openBox<Habit>(_habitBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName); // Open settings box
  }

  Box<Habit> _getHabitBox() {
    if (_habitBox == null || !_habitBox!.isOpen) {
      _habitBox = Hive.box<Habit>(_habitBoxName);
    }
    return _habitBox!;
  }

  Box _getSettingsBox() {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      _settingsBox = Hive.box(_settingsBoxName);
    }
    return _settingsBox!;
  }


  Future<void> addHabit(Habit habit) async {
    await _getHabitBox().put(habit.id, habit);
  }

  Habit? getHabit(String id) {
    return _getHabitBox().get(id);
  }

  List<Habit> getAllHabits() {
    return _getHabitBox().values.toList();
  }

  Future<void> updateHabit(Habit habit) async {
    await _getHabitBox().put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await _getHabitBox().delete(id);
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final habit = getHabit(habitId);
    if (habit != null) {
      final List<DateTime> updatedCompletions = List.from(habit.completedDates);
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (updatedCompletions.any((d) => d.isAtSameMomentAs(dateOnly))) {
        updatedCompletions.removeWhere((d) => d.isAtSameMomentAs(dateOnly));
      } else {
        updatedCompletions.add(dateOnly);
      }
      final updatedHabit = habit.copyWith(completedDates: updatedCompletions);
      await updateHabit(updatedHabit);
    }
  }

  Future<void> close() async {
    await _habitBox?.close();
    await _settingsBox?.close(); // Close settings box too
  }

  Future<void> clearAllData() async {
    await _getHabitBox().clear();
    // Optionally, clear settings box too, or specific keys
    // For now, let's keep theme settings and only clear habits
    // await _getSettingsBox().clear(); // If you want to clear everything
  }

  // --- Export/Import Functionality ---

  Future<String> exportDataToJson() async {
    final habits = getAllHabits();
    // Convert habits to a list of maps for JSON encoding
    final List<Map<String, dynamic>> habitJsonList = habits.map((habit) => habit.toJson()).toList();

    // Include other data if necessary, e.g., settings
    // final settingsData = _getSettingsBox().toMap();
    // final exportData = {
    //   'habits': habitJsonList,
    //   'settings': settingsData, // Example
    // };
    // return jsonEncode(exportData);

    return jsonEncode({'habits': habitJsonList}); // Just habits for now
  }

  Future<bool> importDataFromJson(String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString);

      // Assuming the structure is {'habits': [...]}
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('habits')) {
        final List<dynamic> habitJsonList = jsonData['habits'];

        // Clear existing habits before importing (replace strategy)
        await _getHabitBox().clear();

        for (var habitJson in habitJsonList) {
          if (habitJson is Map<String, dynamic>) {
            final habit = Habit.fromJson(habitJson); // Assumes Habit.fromJson exists
            await addHabit(habit);
          }
        }
        return true; // Import successful
      }
      return false; // Invalid format
    } catch (e) {
      print("Error importing data: $e");
      return false; // Error during import
    }
  }
}

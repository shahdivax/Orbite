import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static const String _habitBoxName = 'habits';

  // Private constructor for singleton pattern
  HiveService._privateConstructor();
  static final HiveService _instance = HiveService._privateConstructor();
  static HiveService get instance => _instance;

  Box<Habit>? _habitBox;

  Future<void> init() async {
    // For web, Hive.initFlutter() is enough.
    // For mobile, getApplicationDocumentsDirectory is needed.
    // This simple check might not be robust for all platforms.
    // Consider using kIsWeb for web check if targeting web.
    try {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
    } catch (e) {
        // Fallback for platforms where getApplicationDocumentsDirectory might not be available
        // (like web, though for web this code path shouldn't be hit if kIsWeb is used)
        print("Error getting document directory: $e. Initializing Hive for web/fallback.");
        await Hive.initFlutter(); // Initialize Hive for Flutter web or as a fallback
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
  }

  Box<Habit> _getHabitBox() {
    if (_habitBox == null || !_habitBox!.isOpen) {
      // This case should ideally not happen if init() is called properly
      // and awaited at app startup.
      // Consider throwing an exception or re-initializing.
      print("Warning: Habit box was not open. Attempting to reopen.");
      // As a fallback, try to get the box again, assuming it was opened.
      // This is not a robust recovery mechanism.
      _habitBox = Hive.box<Habit>(_habitBoxName);
    }
    return _habitBox!;
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
      final dateOnly = DateTime(date.year, date.month, date.day); // Normalize date

      if (updatedCompletions.contains(dateOnly)) {
        updatedCompletions.remove(dateOnly);
      } else {
        updatedCompletions.add(dateOnly);
      }
      // Create a new Habit instance with updated completions
      final updatedHabit = habit.copyWith(completedDates: updatedCompletions);
      await updateHabit(updatedHabit);
    }
  }

  Future<void> close() async {
    await _habitBox?.close();
  }

  // For clearing all data - useful for settings screen
  Future<void> clearAllData() async {
    await _getHabitBox().clear();
  }
}

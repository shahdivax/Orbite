import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/services/hive_service.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull

// Provider for the HiveService instance
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService.instance);

// StateNotifierProvider for managing the list of habits
final habitsProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return HabitNotifier(hiveService);
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  final HiveService _hiveService;

  HabitNotifier(this._hiveService) : super([]) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    state = _hiveService.getAllHabits();
  }

  Future<void> addHabit(Habit habit) async {
    await _hiveService.addHabit(habit);
    // state = [...state, habit]; // Optimistic update
    await loadHabits(); // More robust: reload from source
  }

  Future<void> updateHabit(Habit habit) async {
    await _hiveService.updateHabit(habit);
    // state = [
    //   for (final h in state)
    //     if (h.id == habit.id) habit else h,
    // ]; // Optimistic update
    await loadHabits();
  }

  Future<void> deleteHabit(String habitId) async {
    await _hiveService.deleteHabit(habitId);
    // state = state.where((h) => h.id != habitId).toList(); // Optimistic update
    await loadHabits();
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final habit = state.firstWhereOrNull((h) => h.id == habitId);
    if (habit != null) {
      // Normalize the date to avoid time component issues
      final dateOnly = DateTime(date.year, date.month, date.day);

      List<DateTime> updatedCompletions = List.from(habit.completedDates);

      // Check if the date (without time) is already in the list
      if (updatedCompletions.any((d) =>
          d.year == dateOnly.year &&
          d.month == dateOnly.month &&
          d.day == dateOnly.day)) {
        updatedCompletions.removeWhere((d) =>
          d.year == dateOnly.year &&
          d.month == dateOnly.month &&
          d.day == dateOnly.day);
      } else {
        updatedCompletions.add(dateOnly);
      }

      final updatedHabit = habit.copyWith(completedDates: updatedCompletions);
      await _hiveService.updateHabit(updatedHabit);
      await loadHabits(); // Refresh state from source
    }
  }

  Habit? getHabitById(String id) {
    return state.firstWhereOrNull((habit) => habit.id == id);
  }
}

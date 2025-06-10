import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/add_edit_habit_screen.dart';
import 'package:habit_tracker_app/screens/habit_detail_screen.dart';
import 'package:habit_tracker_app/screens/settings_screen.dart';
import 'package:habit_tracker_app/theme/app_theme.dart';
import 'package:habit_tracker_app/widgets/contribution_grid.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Get the completion status for today
  bool _isCompletedToday(Habit habit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return habit.completedDates.any((date) {
      final completedDate = DateTime(date.year, date.month, date.day);
      return completedDate.isAtSameMomentAs(today);
    });
  }

  // Get the current streak
  int _getCurrentStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final isCompleted = habit.completedDates.any((date) {
        final completedDate = DateTime(date.year, date.month, date.day);
        return completedDate.isAtSameMomentAs(checkDate);
      });
      
      if (isCompleted) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  // Get total completed days
  int _getTotalCompletions(Habit habit) {
    return habit.completedDates.length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Habits',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Habits Grid
            Expanded(
              child: habits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.track_changes,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No habits yet',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to create your first habit',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ListView.builder(
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: _GitHubStyleHabitCard(
                              habit: habit,
                              isCompletedToday: _isCompletedToday(habit),
                              currentStreak: _getCurrentStreak(habit),
                              totalCompletions: _getTotalCompletions(habit),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            
            // Bottom padding for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 8),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditHabitScreen()),
            );
          },
          backgroundColor: AppTheme.fluorescentColors[0],
          foregroundColor: Colors.black,
          elevation: 8,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}

class _GitHubStyleHabitCard extends ConsumerWidget {
  final Habit habit;
  final bool isCompletedToday;
  final int currentStreak;
  final int totalCompletions;

  const _GitHubStyleHabitCard({
    required this.habit,
    required this.isCompletedToday,
    required this.currentStreak,
    required this.totalCompletions,
  });

  // Toggle completion for today
  void _toggleCompletion(WidgetRef ref) {
    final provider = ref.read(habitsProvider.notifier);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (isCompletedToday) {
      // Remove today's completion
      final updatedDates = habit.completedDates.where((date) {
        final completedDay = DateTime(date.year, date.month, date.day);
        return !completedDay.isAtSameMomentAs(today);
      }).toList();
      
      final updatedHabit = habit.copyWith(completedDates: updatedDates);
      provider.updateHabit(updatedHabit);
    } else {
      // Add today's completion
      final updatedDates = [...habit.completedDates, today];
      final updatedHabit = habit.copyWith(completedDates: updatedDates);
      provider.updateHabit(updatedHabit);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitColor = AppTheme.fluorescentColors[
        habit.colorThemeValue % AppTheme.fluorescentColors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habitId: habit.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompletedToday ? habitColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, name and check button
            Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: habitColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: habit.iconEmoji != null && habit.iconEmoji!.isNotEmpty
                        ? Text(
                            habit.iconEmoji!,
                            style: const TextStyle(fontSize: 22),
                          )
                        : Icon(
                            Icons.track_changes,
                            color: habitColor,
                            size: 22,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Name and stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalCompletions contributions in the last year',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Check button
                GestureDetector(
                  onTap: () => _toggleCompletion(ref),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompletedToday ? habitColor : Colors.transparent,
                      border: Border.all(
                        color: habitColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isCompletedToday
                        ? Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 20,
                          )
                        : null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Premium GitHub-style contribution grid
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: habitColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ContributionGrid(
                habit: habit,
                habitColor: habitColor,
                isInteractive: false,
              ),
            ),
            
            // Stats row
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Current streak: $currentStreak days',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: habitColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    habit.frequencyType.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: habitColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

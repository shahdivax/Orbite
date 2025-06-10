import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/add_edit_habit_screen.dart';
import 'package:habit_tracker_app/theme/app_theme.dart';
import 'package:habit_tracker_app/widgets/contribution_grid.dart';
import 'package:intl/intl.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  bool _isEditing = false;

  void _toggleDateCompletion(DateTime date, Habit habit) {
    final provider = ref.read(habitsProvider.notifier);
    final dateToToggle = DateTime(date.year, date.month, date.day);
    
    // Check if this date is already completed
    final isCompleted = habit.completedDates.any((completedDate) {
      final completed = DateTime(completedDate.year, completedDate.month, completedDate.day);
      return completed.isAtSameMomentAs(dateToToggle);
    });
    
    List<DateTime> updatedDates;
    if (isCompleted) {
      // Remove the date
      updatedDates = habit.completedDates.where((completedDate) {
        final completed = DateTime(completedDate.year, completedDate.month, completedDate.day);
        return !completed.isAtSameMomentAs(dateToToggle);
      }).toList();
    } else {
      // Add the date
      updatedDates = [...habit.completedDates, dateToToggle];
    }
    
    final updatedHabit = habit.copyWith(completedDates: updatedDates);
    provider.updateHabit(updatedHabit);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCompleted ? 'Removed completion' : 'Added completion',
        ),
        duration: const Duration(milliseconds: 800),
        backgroundColor: isCompleted ? Colors.red.shade600 : Colors.green.shade600,
      ),
    );
  }

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

  int _getLongestStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    
    final sortedDates = habit.completedDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort();
    
    int maxStreak = 1;
    int currentStreak = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      } else {
        currentStreak = 1;
      }
    }
    
    return maxStreak;
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final habit = habits.firstWhere((h) => h.id == widget.habitId);
    final habitColor = AppTheme.fluorescentColors[
        habit.colorThemeValue % AppTheme.fluorescentColors.length];
    
    final currentStreak = _getCurrentStreak(habit);
    final longestStreak = _getLongestStreak(habit);
    final totalCompletions = habit.completedDates.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                setState(() => _isEditing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit mode disabled'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              } else {
                setState(() => _isEditing = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tap squares to edit completions'),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditHabitScreen(habit: habit),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: habitColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: habitColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: habit.iconEmoji != null && habit.iconEmoji!.isNotEmpty
                              ? Text(
                                  habit.iconEmoji!,
                                  style: const TextStyle(fontSize: 28),
                                )
                              : Icon(
                                  Icons.track_changes,
                                  color: habitColor,
                                  size: 28,
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: habitColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                habit.frequencyType.toString().split('.').last.toUpperCase(),
                                style: TextStyle(
                                  color: habitColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total',
                          value: totalCompletions.toString(),
                          subtitle: 'completions',
                          color: habitColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Current',
                          value: currentStreak.toString(),
                          subtitle: 'day streak',
                          color: habitColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Longest',
                          value: longestStreak.toString(),
                          subtitle: 'day streak',
                          color: habitColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contribution Graph Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalCompletions contributions in the last year',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: habitColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'EDIT MODE',
                      style: TextStyle(
                        color: habitColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Premium Interactive Contribution Grid
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: habitColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: habitColor.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ContributionGrid(
                habit: habit,
                habitColor: habitColor,
                isInteractive: true,
                onDateTap: _isEditing ? (date) => _toggleDateCompletion(date, habit) : null,
              ),
            ),

            const SizedBox(height: 24),

            // Additional Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Started',
                    value: DateFormat('MMMM d, y').format(habit.startDate),
                    color: habitColor,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.repeat,
                    label: 'Frequency',
                    value: habit.frequencyType.toString().split('.').last,
                    color: habitColor,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.timeline,
                    label: 'Days active',
                    value: DateTime.now().difference(habit.startDate).inDays.toString(),
                    color: habitColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

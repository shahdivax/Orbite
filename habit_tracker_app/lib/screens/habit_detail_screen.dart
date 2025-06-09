import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/add_edit_habit_screen.dart';
import 'package:habit_tracker_app/widgets/habit_grid.dart';
import 'package:intl/intl.dart'; // Added for DateFormat

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Attempt to find the habit. If not found, show an error or pop.
    // It's better to pass the full Habit object if possible to avoid this lookup,
    // but if only ID is passed, this is how you'd fetch it.
    // For robustness, ensure habit is available.
    final habit = ref.watch(habitsProvider.select((habits) => habits.firstWhere((h) => h.id == habitId, orElse: null)));

    if (habit == null) {
      // Habit might have been deleted, or ID is incorrect.
      // Pop and show a message or handle appropriately.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit not found. It might have been deleted.')),
        );
      });
      return const Scaffold(body: Center(child: Text("Habit not found.")));
    }

    final Color habitColor = Color(habit.colorThemeValue);
    // Get the base AppBar title style from the theme
    final TextStyle? baseAppBarTitleStyle = Theme.of(context).appBarTheme.titleTextStyle;
    // Create a new style for the title, merging theme style with habit color
    final TextStyle appBarTitleStyleWithHabitColor = (baseAppBarTitleStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)).copyWith(color: habitColor);


    return Scaffold(
      appBar: AppBar(
        // Use the merged style
        title: Text(habit.name, style: appBarTitleStyleWithHabitColor),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Consistent app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditHabitScreen(habit: habit),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Delete Habit'),
                  content: Text('Are you sure you want to delete "${habit.name}"? This action cannot be undone.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                await ref.read(habitsProvider.notifier).deleteHabit(habit.id);
                // Check if context is still mounted before popping
                if (Navigator.canPop(context)) {
                   Navigator.of(context).pop(); // Pop back to home screen
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (habit.iconEmoji != null && habit.iconEmoji!.isNotEmpty)
                  Text(habit.iconEmoji!, style: const TextStyle(fontSize: 36.0)),
                if (habit.iconEmoji != null && habit.iconEmoji!.isNotEmpty)
                  const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    habit.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: habitColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Frequency: ${habit.frequencyType.toString().split('.').last}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Start Date: ${DateFormat.yMMMd().format(habit.startDate)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Activity (Last 365 Days)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            // Hero widget for the grid animation
            Hero(
              tag: 'habitGrid_${habit.id}', // Unique tag for the Hero animation
              child: HabitGrid(
                habit: habit,
                daysToDisplay: 365, // Full year grid
                isMiniMode: false,
              ),
            ),
            // Add more details or stats here if needed
          ],
        ),
      ),
    );
  }
}

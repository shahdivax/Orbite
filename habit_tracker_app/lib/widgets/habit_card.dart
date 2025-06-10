import 'package:flutter/material.dart';
import 'package:habit_tracker_app/models/habit.dart';
// Keep for edit action if needed elsewhere
import 'package:habit_tracker_app/screens/habit_detail_screen.dart'; // Import HabitDetailScreen
import 'package:habit_tracker_app/widgets/habit_grid.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final Color habitColor = Color(habit.colorThemeValue);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(habitId: habit.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0), // Ensure this matches card's border radius
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (habit.iconEmoji != null && habit.iconEmoji!.isNotEmpty)
                    Text(
                      habit.iconEmoji!,
                      style: const TextStyle(fontSize: 24.0),
                    ),
                  if (habit.iconEmoji != null && habit.iconEmoji!.isNotEmpty)
                    const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: habitColor,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Optional: Quick edit button if desired on card itself
                  // IconButton(
                  //   icon: Icon(Icons.edit_note, color: habitColor.withOpacity(0.7)),
                  //   onPressed: (e) {
                  //     e.stopPropagation(); // Prevent card's onTap if button is pressed
                  //     Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditHabitScreen(habit: habit)));
                  //   },
                  // ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Frequency: ${habit.frequencyType.toString().split('.').last}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 70,
                child: Hero( // Wrap the mini grid in a Hero widget
                  tag: 'habitGrid_${habit.id}', // Must match the tag in HabitDetailScreen
                  // Material needed for Hero animation across different routes if there are text style changes etc.
                  child: Material(
                    type: MaterialType.transparency,
                    child: HabitGrid(
                      habit: habit,
                      daysToDisplay: 30,
                      isMiniMode: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

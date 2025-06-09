import 'package:flutter/material.dart';
import 'package:habit_tracker_app/models/habit.dart'; // Import the Habit model

class HabitCard extends StatelessWidget {
  final Habit habit;
  // final VoidCallback onTap; // For navigating to detail screen
  // final Function(DateTime) onToggleDay; // For toggling completion on mini-grid

  const HabitCard({
    super.key,
    required this.habit,
    // required this.onTap,
    // required this.onToggleDay,
  });

  @override
  Widget build(BuildContext context) {
    // Use the habit's color for card elements
    // For simplicity, we'll use the color directly.
    // In a more complex scenario, you might derive shades from this color.
    final Color habitColor = Color(habit.colorThemeValue);

    return Card(
      // The CardTheme from AppTheme should apply (rounded corners, elevation)
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          // TODO: Implement navigation to HabitDetailScreen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on habit: ${habit.name} (Detail view not implemented)')),
          );
        },
        borderRadius: BorderRadius.circular(12.0), // Match Card's shape
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
                      style: const TextStyle(fontSize: 24.0, color: Colors.white), // Emoji color might not be affected by style color
                    ),
                  if (habit.iconEmoji != null && habit.iconEmoji!.isNotEmpty)
                    const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: habitColor, // Use habit color for the name
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Potentially a quick toggle for today's completion
                  // IconButton(
                  //   icon: Icon(
                  //     habit.completedDates.contains(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
                  //         ? Icons.check_circle
                  //         : Icons.radio_button_unchecked,
                  //     color: habitColor,
                  //   ),
                  //   onPressed: () {
                  //     // TODO: Implement quick toggle for today
                  //     // onToggleDay(DateTime.now());
                  //      ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text('Quick toggle for ${habit.name} (not implemented)')),
                  //     );
                  //   },
                  // ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Frequency: ${habit.frequencyType.toString().split('.').last}', // Simple display
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(height: 12.0),
              // Placeholder for the mini GitHub-style grid
              Container(
                height: 50, // Example height
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: habitColor.withOpacity(0.5))
                ),
                child: Center(
                  child: Text(
                    'Mini Grid (30 days) - ${habit.completedDates.length} done',
                    style: TextStyle(color: habitColor, fontSize: 10),
                    textAlign: TextAlign.center,
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

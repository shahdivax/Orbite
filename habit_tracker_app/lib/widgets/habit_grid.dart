import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:intl/intl.dart';

class HabitGrid extends ConsumerWidget {
  final Habit habit;
  final int daysToDisplay;
  final bool isMiniMode;

  const HabitGrid({
    super.key,
    required this.habit,
    this.daysToDisplay = 365,
    this.isMiniMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitColor = Color(habit.colorThemeValue);
    final today = DateTime.now();
    final gridStartDate = today.subtract(Duration(days: daysToDisplay -1));
    final normalizedCompletedDates = habit.completedDates.map((d) {
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMiniMode ? 10 : 20,
        mainAxisSpacing: isMiniMode ? 2.0 : 4.0,
        crossAxisSpacing: isMiniMode ? 2.0 : 4.0,
      ),
      itemCount: daysToDisplay,
      shrinkWrap: true,
      physics: isMiniMode ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final cellDate = gridStartDate.add(Duration(days: index));
        final dateOnly = DateTime(cellDate.year, cellDate.month, cellDate.day);
        final isBeforeHabitStart = dateOnly.isBefore(DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day));
        final isFutureDate = dateOnly.isAfter(DateTime(today.year, today.month, today.day));

        bool isCompleted = false;
        if (!isBeforeHabitStart && !isFutureDate) {
            isCompleted = normalizedCompletedDates.contains(dateOnly);
        }

        Color cellColor;
        if (isBeforeHabitStart || isFutureDate) {
          cellColor = Theme.of(context).colorScheme.surface.withOpacity(0.3);
        } else {
          cellColor = isCompleted ? habitColor : Theme.of(context).colorScheme.surface;
        }

        // Animation properties
        // final double scale = isCompleted ? 1.0 : 0.9; // Example: slightly smaller if not completed
        final Border border = isCompleted
                              ? Border.all(color: habitColor.withOpacity(0.9), width: 1.5)
                              : Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5), width: 0.5);

        return GestureDetector(
          onTap: () {
            if (!isBeforeHabitStart && !isFutureDate) {
              ref.read(habitsProvider.notifier).toggleHabitCompletion(habit.id, dateOnly);
            } else {
              String message = isFutureDate ? "Cannot mark future dates." : "Day is before habit start date.";
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
              );
            }
          },
          child: Tooltip(
            message: isBeforeHabitStart
                     ? 'Before start date'
                     : (isFutureDate
                        ? 'Future date'
                        : '${DateFormat.yMMMd().format(dateOnly)} - ${isCompleted ? "Completed" : "Incomplete"}'),
            child: AnimatedContainer( // Use AnimatedContainer
              duration: const Duration(milliseconds: 200), // Animation duration
              curve: Curves.easeInOut, // Animation curve
              margin: EdgeInsets.all(isCompleted ? 0.5 : 1.0), // Example: margin change
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(isMiniMode ? 2.0 : 4.0),
                border: border, // Animated border
                // Example: add a subtle shadow if completed
                // boxShadow: isCompleted ? [
                //   BoxShadow(
                //     color: habitColor.withOpacity(0.3),
                //     blurRadius: 2,
                //     spreadRadius: 0.5,
                //   )
                // ] : [],
              ),
              // child: Transform.scale( // Example: scale animation (can be combined or alternative)
              //   scale: scale,
              //   child: Container(), // The visual part, if not done by decoration
              // ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:intl/intl.dart';

class ContributionGrid extends StatelessWidget {
  final Habit habit;
  final Color habitColor;
  final bool isInteractive;
  final Function(DateTime)? onDateTap;
  final int weeksToShow;

  const ContributionGrid({
    super.key,
    required this.habit,
    required this.habitColor,
    this.isInteractive = false,
    this.onDateTap,
    this.weeksToShow = 53, // Full year
  });

  // Generate the grid data for a relevant time period
  List<List<DateTime>> _generateGridData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final habitStartDate = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
    
    // Start the grid from the habit start date (or a bit before for context)
    // Find the Monday of the week containing the habit start date
    final daysFromMonday = (habitStartDate.weekday - 1) % 7;
    final firstMonday = habitStartDate.subtract(Duration(days: daysFromMonday));
    
    // Show weeks from habit start forward (full year view)
    List<List<DateTime>> weeks = [];
    
    for (int week = 0; week < weeksToShow; week++) {
      List<DateTime> weekDays = [];
      for (int day = 0; day < 7; day++) {
        final currentDate = firstMonday.add(Duration(days: (week * 7) + day));
        weekDays.add(currentDate);
      }
      weeks.add(weekDays);
    }
    
    return weeks;
  }

  // Generate month labels that match the actual grid data
  List<Map<String, dynamic>> _generateMonthLabels() {
    final gridData = _generateGridData();
    if (gridData.isEmpty) return [];
    
    List<Map<String, dynamic>> monthLabels = [];
    String? lastMonth;
    
    // Track months across the grid
    for (int week = 0; week < gridData.length; week++) {
      // Check if this week contains the first day of a new month or is the first week
      for (int day = 0; day < 7; day++) {
        final date = gridData[week][day];
        final monthName = DateFormat('MMM').format(date);
        
        // Add label if it's a new month or the first week
        if (week == 0 && day == 0) {
          // Always add label for first week
          monthLabels.add({
            'month': monthName,
            'weekIndex': week,
            'date': date,
          });
          lastMonth = monthName;
          break;
        } else if (date.day == 1 && monthName != lastMonth) {
          // Add label for new month
          monthLabels.add({
            'month': monthName,
            'weekIndex': week,
            'date': date,
          });
          lastMonth = monthName;
          break;
        }
      }
    }
    
    return monthLabels;
  }

  // Check if a date is completed
  bool _isDateCompleted(DateTime date) {
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    // Use direct comparison instead of isAtSameMomentAs
    return habit.completedDates.any((completedDate) {
      final completed = DateTime(completedDate.year, completedDate.month, completedDate.day);
      return completed.year == dateToCheck.year &&
             completed.month == dateToCheck.month &&
             completed.day == dateToCheck.day;
    });
  }

  // Get intensity level (0-4) based on completion
  int _getIntensityLevel(DateTime date) {
    return _isDateCompleted(date) ? 4 : 0;
  }

  // Get color based on intensity level
  Color _getSquareColor(int intensity, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    final habitStartDate = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
    
    // Don't show future dates
    if (checkDate.isAfter(today)) {
      return Colors.grey.shade800.withValues(alpha: 0.3);
    }
    
    // Don't show dates before habit started
    if (checkDate.isBefore(habitStartDate)) {
      return Colors.grey.shade900.withValues(alpha: 0.2);
    }
    
    // Make completed dates MUCH more visible with brighter colors
    switch (intensity) {
      case 0:
        return Colors.grey.shade700; // Empty days - slightly lighter
      case 1:
        return habitColor.withValues(alpha: 0.7);
      case 2:
        return habitColor.withValues(alpha: 0.85);
      case 3:
        return habitColor;
      case 4:
        // Use the full habit color with high visibility
        return habitColor;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridData = _generateGridData();
    final monthLabels = _generateMonthLabels();
    final squareSize = isInteractive ? 16.0 : 12.0;
    final spacing = isInteractive ? 3.0 : 2.0;

    return Container(
      padding: EdgeInsets.all(isInteractive ? 16 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month labels - aligned with actual grid data
          Container(
            height: 16,
            margin: EdgeInsets.only(left: isInteractive ? 20 : 0, bottom: 6),
            child: Row(
              children: [
                // Add space for day labels if interactive
                if (isInteractive) SizedBox(width: 20),
                Expanded(
                  child: Stack(
                    children: monthLabels.map((monthData) {
                      final weekIndex = monthData['weekIndex'] as int;
                      final monthName = monthData['month'] as String;
                      final leftPosition = weekIndex * (squareSize + spacing);
                      
                      return Positioned(
                        left: leftPosition,
                        child: Text(
                          monthName,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: isInteractive ? 10 : 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels (only in interactive mode)
              if (isInteractive)
                Container(
                  width: 20,
                  child: Column(
                    children: [
                      // Monday
                      Container(
                        height: squareSize,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      // Tuesday
                      Container(
                        height: squareSize,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'T',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      // Wednesday
                      Container(
                        height: squareSize,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'W',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      // Thursday
                      Container(
                        height: squareSize,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'T',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      // Friday
                      Container(
                        height: squareSize,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'F',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      // Saturday
                      Container(
                        height: squareSize,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'S',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      // Sunday
                      Container(
                        height: squareSize,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'S',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: gridData.map((week) {
                      return Container(
                        margin: EdgeInsets.only(right: spacing),
                        child: Column(
                          children: week.map((date) {
                            final intensity = _getIntensityLevel(date);
                            final squareColor = _getSquareColor(intensity, date);
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final checkDate = DateTime(date.year, date.month, date.day);
                            final habitStartDate = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
                            
                            final isToday = checkDate.isAtSameMomentAs(today);
                            final isFuture = checkDate.isAfter(today);
                            final isBeforeHabitStart = checkDate.isBefore(habitStartDate);
                            final isCompleted = _isDateCompleted(date);
                            
                            // Can only tap if it's interactive, not future, not before start, and has onDateTap
                            final canTap = isInteractive && 
                                          onDateTap != null && 
                                          !isFuture && 
                                          !isBeforeHabitStart;
                            
                            String tooltipMessage;
                            if (isFuture) {
                              tooltipMessage = '${DateFormat('MMM d, y').format(date)}\nFuture date';
                            } else if (isBeforeHabitStart) {
                              tooltipMessage = '${DateFormat('MMM d, y').format(date)}\nBefore habit started';
                            } else {
                              tooltipMessage = '${DateFormat('MMM d, y').format(date)}\n${isCompleted ? "Completed" : "Not completed"}';
                            }
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: spacing),
                              child: Tooltip(
                                message: tooltipMessage,
                                child: GestureDetector(
                                  onTap: canTap ? () => onDateTap!(date) : null,
                                  child: Container(
                                    width: squareSize,
                                    height: squareSize,
                                    decoration: BoxDecoration(
                                      color: squareColor,
                                      borderRadius: BorderRadius.circular(2),
                                      border: isToday
                                          ? Border.all(color: Colors.white, width: 1.5)
                                          : isCompleted
                                              ? Border.all(color: habitColor.withValues(alpha: 0.8), width: 1)
                                              : null,
                                    ),
                                    // Add a more visible indicator for completed dates
                                    child: isCompleted && intensity > 0
                                        ? Icon(
                                            Icons.check,
                                            size: squareSize * 0.6,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          // Legend (only in interactive mode)
          if (isInteractive)
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Less',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(width: 8),
                  for (int i = 0; i <= 4; i++)
                    Container(
                      margin: EdgeInsets.only(right: 3),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getSquareColor(i, DateTime.now()),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  SizedBox(width: 8),
                  Text(
                    'More',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 
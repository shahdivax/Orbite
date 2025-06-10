import 'package:flutter/material.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:intl/intl.dart';

class ContributionGrid extends StatefulWidget {
  final Habit habit;
  final Color habitColor;
  final bool isInteractive;
  final Function(DateTime)? onDateTap;

  const ContributionGrid({
    super.key,
    required this.habit,
    required this.habitColor,
    this.isInteractive = false,
    this.onDateTap,
  });

  @override
  State<ContributionGrid> createState() => _ContributionGridState();
}

class _ContributionGridState extends State<ContributionGrid> {
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentMonth = DateTime(now.year, now.month, 1);
  }

  // Generate horizontal weekly strips for the month
  List<List<DateTime?>> _generateHorizontalWeeks() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    // Find the first Monday to start the week
    final firstMonday = firstDayOfMonth.subtract(Duration(days: (firstDayOfMonth.weekday - 1) % 7));
    
    List<List<DateTime?>> weeks = [];
    
    for (int week = 0; week < 6; week++) {
      List<DateTime?> weekDays = [];
      for (int day = 0; day < 7; day++) {
        final currentDate = firstMonday.add(Duration(days: (week * 7) + day));
        
        // Include all days for visual continuity
        weekDays.add(currentDate);
      }
      weeks.add(weekDays);
      
      // Stop if we've covered the month
      if (weekDays.any((date) => date != null && date.month == currentMonth.month + 1)) {
        break;
      }
    }
    
    return weeks;
  }

  bool _isDateCompleted(DateTime date) {
    final dateToCheck = DateTime(date.year, date.month, date.day);
    return widget.habit.completedDates.any((completedDate) {
      final completed = DateTime(completedDate.year, completedDate.month, completedDate.day);
      return completed.year == dateToCheck.year &&
             completed.month == dateToCheck.month &&
             completed.day == dateToCheck.day;
    });
  }

  Color _getSquareColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    final habitStartDate = DateTime(widget.habit.startDate.year, widget.habit.startDate.month, widget.habit.startDate.day);
    
    final isCompleted = _isDateCompleted(date);
    final isFuture = checkDate.isAfter(today);
    final isBeforeHabitStart = checkDate.isBefore(habitStartDate);
    final isCurrentMonth = date.month == currentMonth.month;
    
    if (isBeforeHabitStart) {
      return Color.lerp(widget.habitColor, Colors.black, 0.85)!;
    } else if (isFuture) {
      return Color.lerp(widget.habitColor, Colors.white, 0.85)!;
    } else if (!isCurrentMonth) {
      return Color.lerp(widget.habitColor, Colors.black, 0.7)!;
    } else if (isCompleted) {
      return widget.habitColor;
    } else {
      return Color.lerp(widget.habitColor, Colors.black, 0.5)!;
    }
  }

  void _navigateMonth(bool forward) {
    setState(() {
      if (forward) {
        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      } else {
        currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gridData = _generateHorizontalWeeks();
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = !widget.isInteractive;
    
    // Increased sizes for better visibility and cooler look
    final squareSize = isCompact ? 12.0 : 18.0; // Increased from 8/14
    final spacing = isCompact ? 3.0 : 4.0; // Increased spacing
    final headerHeight = isCompact ? 50.0 : 70.0; // Increased header

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      child: Column(
        children: [
          // Clean Month Header (no boxes)
          Container(
            height: headerHeight,
            child: Row(
              children: [
                // Previous button - cleaner style
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _navigateMonth(false),
                    child: Container(
                      width: isCompact ? 36 : 44,
                      height: isCompact ? 36 : 44,
                      decoration: BoxDecoration(
                        color: widget.habitColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: widget.habitColor,
                        size: isCompact ? 20 : 24,
                      ),
                    ),
                  ),
                ),
                
                // Month and Year - cleaner typography
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMMM').format(currentMonth),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 20 : 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (!isCompact) ...[
                        SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy').format(currentMonth),
                          style: TextStyle(
                            color: widget.habitColor.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Next button - cleaner style
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _navigateMonth(true),
                    child: Container(
                      width: isCompact ? 36 : 44,
                      height: isCompact ? 36 : 44,
                      decoration: BoxDecoration(
                        color: widget.habitColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: widget.habitColor,
                        size: isCompact ? 20 : 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isCompact ? 16 : 24),
          
          // Day Labels - better spacing
          if (widget.isInteractive) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'].map((day) => 
                  SizedBox(
                    width: squareSize * 1.1,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: isCompact ? 10 : 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ),
            SizedBox(height: 16),
          ],
          
          // Premium Grid Layout - bigger and cooler
          Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20),
            child: Column(
              children: gridData.map((week) {
                return Container(
                  margin: EdgeInsets.only(bottom: spacing),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: week.map((date) {
                      if (date == null) {
                        return SizedBox(
                          width: squareSize,
                          height: squareSize,
                        );
                      }
                      
                      final squareColor = _getSquareColor(date);
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final checkDate = DateTime(date.year, date.month, date.day);
                      final habitStartDate = DateTime(widget.habit.startDate.year, widget.habit.startDate.month, widget.habit.startDate.day);
                      
                      final isToday = checkDate.isAtSameMomentAs(today);
                      final isFuture = checkDate.isAfter(today);
                      final isBeforeHabitStart = checkDate.isBefore(habitStartDate);
                      final isCompleted = _isDateCompleted(date);
                      
                      final canTap = widget.isInteractive && 
                                    widget.onDateTap != null && 
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
                      
                      return Tooltip(
                        message: tooltipMessage,
                        child: GestureDetector(
                          onTap: canTap ? () => widget.onDateTap!(date) : null,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: squareSize,
                            height: squareSize,
                            decoration: BoxDecoration(
                              color: squareColor,
                              borderRadius: BorderRadius.circular(squareSize * 0.25), // More rounded
                              border: isToday
                                  ? Border.all(
                                      color: Colors.white,
                                      width: isCompact ? 2.0 : 3.0, // Thicker border
                                    )
                                  : null,
                              boxShadow: isCompleted && date.month == currentMonth.month
                                  ? [
                                      BoxShadow(
                                        color: widget.habitColor.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
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
          
          // Premium Legend - cleaner style
          if (widget.isInteractive) ...[
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPremiumLegendItem(
                    'Before Start',
                    Color.lerp(widget.habitColor, Colors.black, 0.85)!,
                  ),
                  _buildPremiumLegendItem(
                    'Missed',
                    Color.lerp(widget.habitColor, Colors.black, 0.5)!,
                  ),
                  _buildPremiumLegendItem(
                    'Completed',
                    widget.habitColor,
                  ),
                  _buildPremiumLegendItem(
                    'Future',
                    Color.lerp(widget.habitColor, Colors.white, 0.85)!,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPremiumLegendItem(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 14, // Increased legend square size
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
} 
import 'package:home_widget/home_widget.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class WidgetService {
  static const String _androidProviderName = 'HabitWidgetProvider';
  static const String _iOSWidgetKind = 'HabitWidget';

  static Future<void> updateHabitWidget(Habit habit) async {
    try {
      final habitColor = AppTheme.fluorescentColors[
          habit.colorThemeValue % AppTheme.fluorescentColors.length];

      // Calculate current streak
      final currentStreak = _getCurrentStreak(habit);
      final totalCompletions = habit.completedDates.length;
      final isCompletedToday = _isCompletedToday(habit);

      // Prepare widget data
      await HomeWidget.saveWidgetData<String>('habit_name', habit.name);
      await HomeWidget.saveWidgetData<String>('habit_emoji', habit.iconEmoji ?? '📈');
      await HomeWidget.saveWidgetData<int>('current_streak', currentStreak);
      await HomeWidget.saveWidgetData<int>('total_completions', totalCompletions);
      await HomeWidget.saveWidgetData<bool>('completed_today', isCompletedToday);
      await HomeWidget.saveWidgetData<String>('habit_color', habitColor.value.toRadixString(16));
      await HomeWidget.saveWidgetData<String>('habit_id', habit.id);

      // Generate mini grid for last 7 days
      final miniGrid = _generateMiniGrid(habit);
      await HomeWidget.saveWidgetData<String>('mini_grid', miniGrid);

      // Update the widget
      await HomeWidget.updateWidget(
        androidName: _androidProviderName,
        iOSName: _iOSWidgetKind,
      );
    } catch (e) {
      print('Error updating habit widget: $e');
    }
  }

  static Future<void> updateAllHabitWidgets(List<Habit> habits) async {
    for (final habit in habits) {
      await updateHabitWidget(habit);
    }
  }

  static String _generateMiniGrid(Habit habit) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final List<String> gridData = [];

    // Generate last 14 days of current month for mini widget
    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final habitStartDate = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
      
      final isCompleted = habit.completedDates.any((completedDate) {
        final completed = DateTime(completedDate.year, completedDate.month, completedDate.day);
        final checkDate = DateTime(date.year, date.month, date.day);
        return completed.isAtSameMomentAs(checkDate);
      });
      
      final isBeforeHabitStart = date.isBefore(habitStartDate);
      final isFuture = date.isAfter(now);
      
      // Use different states: 0=missed, 1=completed, 2=future, 3=before_start
      if (isBeforeHabitStart) {
        gridData.add('3');
      } else if (isFuture) {
        gridData.add('2');
      } else if (isCompleted) {
        gridData.add('1');
      } else {
        gridData.add('0');
      }
    }

    return gridData.join(',');
  }

  static int _getCurrentStreak(Habit habit) {
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

  static bool _isCompletedToday(Habit habit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return habit.completedDates.any((completedDate) {
      final completed = DateTime(completedDate.year, completedDate.month, completedDate.day);
      return completed.isAtSameMomentAs(today);
    });
  }

  static Future<void> registerBackgroundUpdate() async {
    try {
      await HomeWidget.registerBackgroundCallback(backgroundCallback);
    } catch (e) {
      print('Error registering background callback: $e');
    }
  }

  static Future<void> backgroundCallback(Uri? uri) async {
    // Handle widget interactions like marking habit as complete
    if (uri != null) {
      print('Widget interaction: $uri');
    }
  }
} 
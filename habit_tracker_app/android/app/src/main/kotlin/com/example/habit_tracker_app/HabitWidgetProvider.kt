package com.example.habit_tracker_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class HabitWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.habit_widget_layout)

        val habitName = widgetData.getString("habit_name", "Habit") ?: "Habit"
        val habitEmoji = widgetData.getString("habit_emoji", "📈") ?: "📈"
        val currentStreak = widgetData.getInt("current_streak", 0)
        val totalCompletions = widgetData.getInt("total_completions", 0)
        val completedToday = widgetData.getBoolean("completed_today", false)
        val habitColorStr = widgetData.getString("habit_color", "FF6B6B") ?: "FF6B6B"
        val miniGridStr = widgetData.getString("mini_grid", "0,0,0,0,0,0,0,0,0,0,0,0,0,0") ?: "0,0,0,0,0,0,0,0,0,0,0,0,0,0"

        // Update text views
        views.setTextViewText(R.id.habit_name, habitName)
        views.setTextViewText(R.id.habit_emoji, habitEmoji)
        views.setTextViewText(R.id.current_streak, "🔥 $currentStreak")
        views.setTextViewText(R.id.total_completions, totalCompletions.toString())
        views.setTextViewText(R.id.completed_today, if (completedToday) "✅" else "❌")

        // Parse habit color with null safety
        val habitColor = try {
            Color.parseColor("#$habitColorStr")
        } catch (e: Exception) {
            Color.parseColor("#FF6B6B")
        }

        // Update mini grid with new color logic
        val gridData = miniGridStr.split(",")
        val gridViews = arrayOf(
            R.id.grid_day_0, R.id.grid_day_1, R.id.grid_day_2, R.id.grid_day_3,
            R.id.grid_day_4, R.id.grid_day_5, R.id.grid_day_6, R.id.grid_day_7,
            R.id.grid_day_8, R.id.grid_day_9, R.id.grid_day_10, R.id.grid_day_11,
            R.id.grid_day_12, R.id.grid_day_13
        )

        for (i in gridViews.indices) {
            if (i < gridData.size) {
                val state = gridData[i]
                val color = when (state) {
                    "0" -> blendColors(habitColor, Color.BLACK, 0.4f) // Missed days
                    "1" -> habitColor // Completed days
                    "2" -> blendColors(habitColor, Color.WHITE, 0.8f) // Future days
                    "3" -> blendColors(habitColor, Color.BLACK, 0.8f) // Before habit start
                    else -> blendColors(habitColor, Color.BLACK, 0.4f)
                }
                views.setInt(gridViews[i], "setBackgroundColor", color)
            }
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    // Helper function to blend colors (similar to Color.lerp in Flutter)
    private fun blendColors(color1: Int, color2: Int, ratio: Float): Int {
        val inverseRatio = 1f - ratio
        val r = (Color.red(color1) * inverseRatio + Color.red(color2) * ratio).toInt()
        val g = (Color.green(color1) * inverseRatio + Color.green(color2) * ratio).toInt()
        val b = (Color.blue(color1) * inverseRatio + Color.blue(color2) * ratio).toInt()
        return Color.rgb(r, g, b)
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
} 
package com.wigt.wigt

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WigtWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.wigt_widget).apply {
                // PendingIntent to launch app
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                val dayTitle = widgetData.getString("day_title", "Hoy") ?: "Hoy"
                val dateSubtitle = widgetData.getString("date_subtitle", "") ?: ""
                val countText = widgetData.getString("tasks_count", "0 pendientes") ?: "0 pendientes"
                val task1 = widgetData.getString("task_1", "") ?: ""
                val task2 = widgetData.getString("task_2", "") ?: ""
                val task3 = widgetData.getString("task_3", "") ?: ""
                val task4 = widgetData.getString("task_4", "") ?: ""
                val moreCount = widgetData.getString("more_count", "") ?: ""
                val isEmpty = widgetData.getBoolean("is_empty", true)

                setTextViewText(R.id.widget_day_title, dayTitle)
                setTextViewText(R.id.widget_date_subtitle, dateSubtitle)
                setTextViewText(R.id.widget_count, countText)

                if (isEmpty || (task1.isEmpty() && task2.isEmpty() && task3.isEmpty() && task4.isEmpty())) {
                    setViewVisibility(R.id.widget_empty_container, View.VISIBLE)
                    setViewVisibility(R.id.widget_tasks_container, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_empty_container, View.GONE)
                    setViewVisibility(R.id.widget_tasks_container, View.VISIBLE)

                    // Task 1
                    if (task1.isNotEmpty()) {
                        setViewVisibility(R.id.widget_task_1_row, View.VISIBLE)
                        setTextViewText(R.id.widget_task_1_text, task1)
                    } else {
                        setViewVisibility(R.id.widget_task_1_row, View.GONE)
                    }

                    // Task 2
                    if (task2.isNotEmpty()) {
                        setViewVisibility(R.id.widget_task_2_row, View.VISIBLE)
                        setTextViewText(R.id.widget_task_2_text, task2)
                    } else {
                        setViewVisibility(R.id.widget_task_2_row, View.GONE)
                    }

                    // Task 3
                    if (task3.isNotEmpty()) {
                        setViewVisibility(R.id.widget_task_3_row, View.VISIBLE)
                        setTextViewText(R.id.widget_task_3_text, task3)
                    } else {
                        setViewVisibility(R.id.widget_task_3_row, View.GONE)
                    }

                    // Task 4
                    if (task4.isNotEmpty()) {
                        setViewVisibility(R.id.widget_task_4_row, View.VISIBLE)
                        setTextViewText(R.id.widget_task_4_text, task4)
                    } else {
                        setViewVisibility(R.id.widget_task_4_row, View.GONE)
                    }

                    // More counter
                    if (moreCount.isNotEmpty()) {
                        setViewVisibility(R.id.widget_more_text, View.VISIBLE)
                        setTextViewText(R.id.widget_more_text, moreCount)
                    } else {
                        setViewVisibility(R.id.widget_more_text, View.GONE)
                    }
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

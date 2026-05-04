package com.example.moodly

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class MoodlyWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)

            val showCategory = widgetData.getBoolean("showCategory", true)
            val showQuote = widgetData.getBoolean("showQuote", true)
            val useBackground = widgetData.getBoolean("useBackground", true)

            val category = widgetData.getString(
                "previewCategory",
                "Kesehatan Mental"
            ) ?: "Kesehatan Mental"

            val quote = widgetData.getString(
                "previewQuote",
                "Aku boleh beristirahat tanpa merasa bersalah."
            ) ?: "Aku boleh beristirahat tanpa merasa bersalah."

            val textColor = getIntValue(
                widgetData,
                "textColor",
                android.graphics.Color.WHITE
            )

            val overlayColor = getIntValue(
                widgetData,
                "overlayColor",
                0x33000000.toInt()
            )

            val backgroundRes = R.drawable.widget_bg_1

            val views = RemoteViews(context.packageName, R.layout.moodly_widget)

            views.setImageViewResource(R.id.widget_background, backgroundRes)

            views.setViewVisibility(
                R.id.widget_background,
                if (useBackground) View.VISIBLE else View.GONE
            )

            views.setTextViewText(R.id.widget_category, category)
            views.setTextViewText(R.id.widget_quote, quote)

            views.setTextColor(R.id.widget_quote, textColor)
            views.setInt(R.id.widget_overlay, "setBackgroundColor", overlayColor)

            views.setViewVisibility(
                R.id.widget_category,
                if (showCategory) View.VISIBLE else View.GONE
            )

            views.setViewVisibility(
                R.id.widget_quote,
                if (showQuote) View.VISIBLE else View.GONE
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

private fun getIntValue(
    widgetData: android.content.SharedPreferences,
    key: String,
    defaultValue: Int
): Int {
    val value = widgetData.all[key]
    return when (value) {
        is Int -> value
        is Long -> value.toInt()
        is Float -> value.toInt()
        is Double -> value.toInt()
        is String -> value.toIntOrNull() ?: defaultValue
        else -> defaultValue
    }
}
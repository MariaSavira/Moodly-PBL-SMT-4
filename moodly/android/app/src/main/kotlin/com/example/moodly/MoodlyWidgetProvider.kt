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

            val languageCode = widgetData.getString("languageCode", "id") ?: "id"

            val rawCategory = widgetData.getString(
                "previewCategory",
                defaultCategory(languageCode)
            ) ?: defaultCategory(languageCode)

            val category = localizedCategory(rawCategory, languageCode)

            val quote = widgetData.getString(
                "previewQuote",
                defaultQuote(languageCode)
            ) ?: defaultQuote(languageCode)

            val textColor = getIntValue(
                widgetData,
                "textColor",
                android.graphics.Color.WHITE
            )

            val selectedWallpaper = widgetData.getString(
                "selectedWallpaper",
                "assets/icon/images/bg_afirmasi_1.jpg"
            ) ?: "assets/icon/images/bg_afirmasi_1.jpg"

            val backgroundRes = when (selectedWallpaper) {
                "assets/icon/images/bg_afirmasi_1.jpg" -> R.drawable.widget_bg_1
                "assets/icon/images/bg_afirmasi_2.jpg" -> R.drawable.widget_bg_2
                "assets/icon/images/bg_afirmasi_3.jpg" -> R.drawable.widget_bg_3
                "assets/icon/images/bg_afirmasi_4.jpg" -> R.drawable.widget_bg_4
                "assets/icon/images/bg_afirmasi_5.jpg" -> R.drawable.widget_bg_5
                else -> R.drawable.widget_bg_1
            }

            val views = RemoteViews(context.packageName, R.layout.moodly_widget)

            views.setImageViewResource(R.id.widget_background, backgroundRes)
            views.setTextViewText(R.id.widget_category, category)
            views.setTextViewText(R.id.widget_quote, quote)
            views.setTextColor(R.id.widget_quote, textColor)
            views.setTextColor(R.id.widget_category, android.graphics.Color.parseColor("#202020"))

            views.setViewVisibility(
                R.id.widget_background,
                if (useBackground) View.VISIBLE else View.GONE
            )

            views.setViewVisibility(
                R.id.widget_scrim,
                if (useBackground) View.VISIBLE else View.GONE
            )

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

private fun defaultCategory(languageCode: String): String {
    return if (languageCode == "en") "Mental Health" else "Kesehatan Mental"
}

private fun defaultQuote(languageCode: String): String {
    return if (languageCode == "en") {
        "I am allowed to rest without feeling guilty."
    } else {
        "Aku boleh beristirahat tanpa merasa bersalah."
    }
}

private fun localizedCategory(category: String, languageCode: String): String {
    if (languageCode != "en") return category

    return when (category.trim()) {
        "Rasa Syukur" -> "Gratitude"
        "Meredakan Kecemasan" -> "Ease Anxiety"
        "Motivasi" -> "Motivation"
        "Kesehatan Mental" -> "Mental Health"
        "Cinta Diri" -> "Self Love"
        "Afirmasi" -> "Affirmation"
        else -> category
    }
}
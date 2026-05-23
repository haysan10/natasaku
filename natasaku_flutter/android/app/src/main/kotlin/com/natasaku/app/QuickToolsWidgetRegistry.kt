package com.natasaku.app

import android.content.Context

object QuickToolsWidgetRegistry {
    private val providers: List<Class<out android.appwidget.AppWidgetProvider>> = listOf(
        Widget1CompactProvider::class.java,
        Widget2TodayProvider::class.java,
        Widget3QuickActionsProvider::class.java,
        Widget4ProgressProvider::class.java,
        Widget5ListProvider::class.java,
        Widget6FocusProvider::class.java,
        Widget7DashboardProvider::class.java,
        Widget8MinimalProvider::class.java
    )

    fun refreshAll(context: Context) {
        providers.forEach { providerClass ->
            BaseQuickToolsWidgetProvider.refreshProvider(context, providerClass)
        }
    }
}

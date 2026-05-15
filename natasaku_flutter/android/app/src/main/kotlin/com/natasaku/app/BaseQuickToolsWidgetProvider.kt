package com.natasaku.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

abstract class BaseQuickToolsWidgetProvider(private val layoutId: Int) : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    protected abstract fun bindViews(context: Context, views: RemoteViews, state: QuickToolsState)

    private fun updateWidget(context: Context, manager: AppWidgetManager, appWidgetId: Int) {
        val state = QuickToolsStateStore.load(context)
        val views = RemoteViews(context.packageName, layoutId)
        bindViews(context, views, state)
        manager.updateAppWidget(appWidgetId, views)
    }

    protected fun openAppIntent(context: Context, requestCode: Int, action: String): PendingIntent {
        return PendingIntent.getActivity(
            context,
            requestCode,
            Intent(context, MainActivity::class.java).apply {
                putExtra(QuickToolsContract.intentActionKey, action)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    protected fun quickExpenseIntent(context: Context, requestCode: Int, action: String): PendingIntent {
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            Intent(context, QuickToolsActionReceiver::class.java).apply {
                this.action = action
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    companion object {
        fun refreshProvider(context: Context, providerClass: Class<out AppWidgetProvider>) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, providerClass))
            if (ids.isNotEmpty()) {
                val intent = Intent(context, providerClass).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }
                context.sendBroadcast(intent)
            }
        }
    }
}

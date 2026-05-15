package com.natasaku.app

import android.content.Context
import android.widget.RemoteViews

class Widget8MinimalProvider : BaseQuickToolsWidgetProvider(R.layout.widget_8_minimal) {
    override fun bindViews(context: Context, views: RemoteViews, state: QuickToolsState) {
        views.setTextViewText(R.id.tv_safe, state.dailySafeBudgetText)
        views.setTextViewText(R.id.tv_status, state.dailyStatus)
        views.setOnClickPendingIntent(
            R.id.rootWidget,
            openAppIntent(context, 8001, QuickToolsContract.actionOpen)
        )
    }
}

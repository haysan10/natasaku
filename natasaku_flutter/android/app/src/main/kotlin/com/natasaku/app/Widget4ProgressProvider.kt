package com.natasaku.app

import android.content.Context
import android.widget.RemoteViews

class Widget4ProgressProvider : BaseQuickToolsWidgetProvider(R.layout.widget_4_progress) {
    override fun bindViews(context: Context, views: RemoteViews, state: QuickToolsState) {
        views.setProgressBar(R.id.progress_bar, 100, state.usagePercent, false)
        views.setTextViewText(R.id.tv_percent, "${state.usagePercent}%")
        views.setTextViewText(R.id.tv_hint, state.dailyStatus)
        views.setOnClickPendingIntent(
            R.id.rootWidget,
            openAppIntent(context, 4001, QuickToolsContract.actionCheck)
        )
    }
}

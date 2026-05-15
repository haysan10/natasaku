package com.natasaku.app

import android.content.Context
import android.widget.RemoteViews

class Widget6FocusProvider : BaseQuickToolsWidgetProvider(R.layout.widget_6_focus) {
    override fun bindViews(context: Context, views: RemoteViews, state: QuickToolsState) {
        views.setTextViewText(R.id.tv_advice, state.advice)
        views.setTextViewText(R.id.tv_meta, "${state.remainingDays} · ${state.dailyStatus}")
        views.setOnClickPendingIntent(
            R.id.btn_action_1,
            quickExpenseIntent(context, 6001, QuickToolsContract.receiverActionQuickExpense10k)
        )
        views.setOnClickPendingIntent(
            R.id.btn_action_2,
            openAppIntent(context, 6002, QuickToolsContract.actionCheck)
        )
    }
}

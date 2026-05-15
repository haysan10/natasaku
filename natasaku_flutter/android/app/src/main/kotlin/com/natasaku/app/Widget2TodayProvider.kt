package com.natasaku.app

import android.content.Context
import android.widget.RemoteViews

class Widget2TodayProvider : BaseQuickToolsWidgetProvider(R.layout.widget_2_today) {
    override fun bindViews(context: Context, views: RemoteViews, state: QuickToolsState) {
        views.setTextViewText(R.id.tv_expense, state.todayExpenseText)
        views.setTextViewText(R.id.tv_safe, "Batas: ${state.dailySafeBudgetText}")
        views.setTextViewText(R.id.tv_status, state.dailyStatus)
        views.setOnClickPendingIntent(
            R.id.btn_action_1,
            quickExpenseIntent(context, 2001, QuickToolsContract.receiverActionQuickExpense10k)
        )
        views.setOnClickPendingIntent(
            R.id.btn_action_2,
            openAppIntent(context, 2002, QuickToolsContract.actionOpen)
        )
    }
}

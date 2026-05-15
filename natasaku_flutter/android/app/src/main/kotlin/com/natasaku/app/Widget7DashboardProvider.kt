package com.natasaku.app

import android.content.Context
import android.widget.RemoteViews

class Widget7DashboardProvider : BaseQuickToolsWidgetProvider(R.layout.widget_7_dashboard) {
    override fun bindViews(context: Context, views: RemoteViews, state: QuickToolsState) {
        views.setTextViewText(R.id.tv_expense, "Keluar: ${state.todayExpenseText}")
        views.setTextViewText(R.id.tv_safe, "Batas: ${state.dailySafeBudgetText}")
        views.setTextViewText(R.id.tv_fund, "Sisa Dana: ${state.remainingFundText}")
        views.setTextViewText(R.id.tv_period, state.periodStatus)
        views.setTextViewText(R.id.tv_advice, state.advice)

        views.setOnClickPendingIntent(
            R.id.btn_action_1,
            quickExpenseIntent(context, 7001, QuickToolsContract.receiverActionQuickExpense10k)
        )
        views.setOnClickPendingIntent(
            R.id.btn_action_2,
            quickExpenseIntent(context, 7002, QuickToolsContract.receiverActionQuickExpense50k)
        )
        views.setOnClickPendingIntent(
            R.id.btn_action_3,
            openAppIntent(context, 7003, QuickToolsContract.actionOpen)
        )
    }
}

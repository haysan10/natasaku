package com.natasaku.app

import android.content.Context
import android.widget.RemoteViews

class Widget3QuickActionsProvider : BaseQuickToolsWidgetProvider(R.layout.widget_3_quick_actions) {
    override fun bindViews(context: Context, views: RemoteViews, state: QuickToolsState) {
        views.setTextViewText(R.id.tv_caption, state.remainingDays)
        views.setOnClickPendingIntent(
            R.id.btn_action_1,
            quickExpenseIntent(context, 3001, QuickToolsContract.receiverActionQuickExpense10k)
        )
        views.setOnClickPendingIntent(
            R.id.btn_action_2,
            quickExpenseIntent(context, 3002, QuickToolsContract.receiverActionQuickExpense50k)
        )
        views.setOnClickPendingIntent(
            R.id.btn_action_3,
            openAppIntent(context, 3003, QuickToolsContract.actionCheck)
        )
    }
}

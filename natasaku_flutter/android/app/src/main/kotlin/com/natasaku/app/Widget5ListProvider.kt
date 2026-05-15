package com.natasaku.app

import android.content.Context
import android.widget.RemoteViews

class Widget5ListProvider : BaseQuickToolsWidgetProvider(R.layout.widget_5_list) {
    override fun bindViews(context: Context, views: RemoteViews, state: QuickToolsState) {
        views.setTextViewText(R.id.tv_item_1_value, state.todayExpenseText)
        views.setTextViewText(R.id.tv_item_2_value, state.remainingFundText)
        views.setTextViewText(R.id.tv_item_3_value, state.dailySafeBudgetText)
        views.setOnClickPendingIntent(
            R.id.btn_action_1,
            openAppIntent(context, 5001, QuickToolsContract.actionOpen)
        )
        views.setOnClickPendingIntent(
            R.id.btn_action_2,
            openAppIntent(context, 5002, QuickToolsContract.actionQuickAdd)
        )
    }
}

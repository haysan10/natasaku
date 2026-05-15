package com.natasaku.app

import android.content.Context
import android.widget.RemoteViews

class Widget1CompactProvider : BaseQuickToolsWidgetProvider(R.layout.widget_1_compact) {
    override fun bindViews(context: Context, views: RemoteViews, state: QuickToolsState) {
        views.setTextViewText(R.id.tv_amount, state.dailySafeBudgetText)
        views.setOnClickPendingIntent(
            R.id.rootWidget,
            quickExpenseIntent(context, 1001, QuickToolsContract.receiverActionQuickExpense10k)
        )
    }
}

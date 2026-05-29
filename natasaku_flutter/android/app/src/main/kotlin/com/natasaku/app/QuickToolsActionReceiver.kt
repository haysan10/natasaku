package com.natasaku.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class QuickToolsActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            QuickToolsContract.receiverActionQuickExpense10k -> handleQuickExpense(context, 10_000L)
            QuickToolsContract.receiverActionQuickExpense50k -> handleQuickExpense(context, 50_000L)
            QuickToolsContract.receiverActionOpen -> launchApp(context, QuickToolsContract.actionOpen)
            QuickToolsContract.receiverActionCheck -> launchApp(context, QuickToolsContract.actionCheck)
            QuickToolsContract.receiverActionQuickAdd -> launchApp(context, QuickToolsContract.actionQuickAdd)
            QuickToolsContract.receiverActionSimulasi -> launchApp(context, QuickToolsContract.actionSimulasi)
        }
    }

    private fun handleQuickExpense(context: Context, amount: Long) {
        val updatedState = QuickToolsStateStore.registerQuickExpense(context, amount)
        QuickToolsWidgetRegistry.refreshAll(context)
        QuickToolsNotificationManager.showOrUpdate(context, updatedState)
        QuickToolsNotificationManager.showQuickExpenseReceipt(context, amount, updatedState)
    }

    private fun launchApp(context: Context, action: String) {
        val appIntent = Intent(context, MainActivity::class.java).apply {
            putExtra(QuickToolsContract.intentActionKey, action)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        context.startActivity(appIntent)
    }
}

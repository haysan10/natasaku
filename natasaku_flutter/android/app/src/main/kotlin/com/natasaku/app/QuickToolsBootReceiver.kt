package com.natasaku.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class QuickToolsBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON" -> {
                QuickToolsWidgetRegistry.refreshAll(context)
                QuickToolsNotificationManager.showOrUpdate(context)
            }
        }
    }
}

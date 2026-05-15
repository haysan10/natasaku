package com.natasaku.app.reminder

import android.content.Context
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

private const val DAILY_UPDATE_WORK_NAME = "daily_update_work"

class ReminderScheduler(private val context: Context) {
    fun sync(enabled: Boolean) {
        val wm = WorkManager.getInstance(context)
        if (!enabled) {
            wm.cancelUniqueWork(DAILY_UPDATE_WORK_NAME)
            return
        }
        val request = PeriodicWorkRequestBuilder<ReminderWorker>(1, TimeUnit.HOURS).build()
        wm.enqueueUniquePeriodicWork(
            DAILY_UPDATE_WORK_NAME,
            ExistingPeriodicWorkPolicy.UPDATE,
            request,
        )
        wm.enqueue(OneTimeWorkRequestBuilder<ReminderWorker>().build())
    }
}

package com.natasaku.app.reminder

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import java.time.LocalDateTime
import java.time.ZoneId

class ExpenseReminderScheduler(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private val store = ExpenseReminderStore(context)

    fun scheduleNext() {
        val now = LocalDateTime.now()
        val reminderHours = store.getReminderHours()
        val next = computeNextTrigger(now, reminderHours)

        val millis = next.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
        val intent = Intent(context, ExpenseReminderReceiver::class.java).apply {
            action = ExpenseReminderReceiver.ACTION_CHECK_DAILY_EXPENSE
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_ALARM,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        alarmManager.cancel(pendingIntent)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && alarmManager.canScheduleExactAlarms()) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, millis, pendingIntent)
        } else {
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, millis, pendingIntent)
        }
    }

    fun cancelAll() {
        val intent = Intent(context, ExpenseReminderReceiver::class.java).apply {
            action = ExpenseReminderReceiver.ACTION_CHECK_DAILY_EXPENSE
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_ALARM,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        alarmManager.cancel(pendingIntent)
    }

    private fun computeNextTrigger(now: LocalDateTime, hours: List<Int>): LocalDateTime {
        val today = now.toLocalDate()

        val todayCandidate = hours
            .map { today.atTime(it, 0) }
            .firstOrNull { it.isAfter(now.plusMinutes(1)) }

        if (todayCandidate != null) return todayCandidate

        val nextDay = today.plusDays(1)
        val firstHour = hours.firstOrNull() ?: 11
        return nextDay.atTime(firstHour, 0)
    }

    companion object {
        private const val REQUEST_CODE_ALARM = 33001
    }
}

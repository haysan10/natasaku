package com.natasaku.app.reminder

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.natasaku.app.R
import com.natasaku.app.data.datastore.UserPreferenceDataStore
import com.natasaku.app.data.local.database.DatabaseProvider
import com.natasaku.app.domain.model.FixedExpenseStatus
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import kotlinx.coroutines.flow.first
import kotlin.math.absoluteValue

private const val CHANNEL_ID = "daily_update_channel"

class ReminderWorker(
    appContext: Context,
    params: WorkerParameters,
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        val prefs = UserPreferenceDataStore(applicationContext).preferences.first()
        if (!prefs.dailyReminderEnabled) return Result.success()

        val now = java.time.ZonedDateTime.now()
        val nowTime = now.toLocalTime()
        if (nowTime.isBefore(LocalTime.of(7, 0)) || nowTime.isAfter(LocalTime.of(18, 0))) {
            return Result.success()
        }

        val db = DatabaseProvider.get(applicationContext)
        val period = db.budgetPeriodDao().observeActivePeriod().first() ?: return Result.success()
        val fixedExpenses = db.fixedExpenseDao().observeByPeriod(period.id).first()

        val todayDay = LocalDate.now().dayOfMonth
        fixedExpenses
            .filter { it.status == FixedExpenseStatus.COMMITTED && todayDay >= it.dueDay }
            .forEach { db.fixedExpenseDao().updateStatus(it.id, FixedExpenseStatus.PENDING) }

        val refreshed = db.fixedExpenseDao().observeByPeriod(period.id).first()
        val dueItems = refreshed.filter {
            it.status == FixedExpenseStatus.PENDING &&
                (it.snoozedUntilTs == null || !it.snoozedUntilTs.isAfter(Instant.now()))
        }
        if (dueItems.isEmpty()) return Result.success()

        val allowedNagHours = setOf(7, 9, 11, 13, 15, 17)
        if (now.hour !in allowedNagHours) return Result.success()

        val shared = applicationContext.getSharedPreferences("natasaku_reminder", Context.MODE_PRIVATE)
        val slotKey = "${LocalDate.now()}-${now.hour}"
        val lastSlot = shared.getString("last_nag_slot", null)
        if (lastSlot == slotKey) return Result.success()

        if (!hasNotificationPermission(applicationContext)) return Result.success()

        createChannel(applicationContext)
        dueItems.forEach { item ->
            val notificationId = 20000 + item.id.hashCode().absoluteValue % 10000
            val paidIntent = actionPendingIntent(ReminderActionReceiver.ACTION_MARK_PAID, item.id, notificationId, notificationId + 1)
            val snoozeIntent = actionPendingIntent(ReminderActionReceiver.ACTION_SNOOZE_2H, item.id, notificationId, notificationId + 2)
            val rescheduleIntent = actionPendingIntent(ReminderActionReceiver.ACTION_RESCHEDULE, item.id, notificationId, notificationId + 3)

            val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_notification_small)
                .setContentTitle("Pembayaran Jatuh Tempo")
                .setContentText("${item.name} - Rp ${item.amount}")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .addAction(0, "Paid", paidIntent)
                .addAction(0, "Snooze 2h", snoozeIntent)
                .addAction(0, "Reschedule", rescheduleIntent)
                .build()
            NotificationManagerCompat.from(applicationContext).notify(notificationId, notification)
        }
        shared.edit().putString("last_nag_slot", slotKey).apply()

        // Honor reminder time by sending a gentle reminder once/day after configured time.
        runCatching {
            val reminderTime = LocalTime.parse(prefs.dailyReminderTime)
            if (!nowTime.isBefore(reminderTime)) {
                val dayKey = LocalDate.now().toString()
                val lastDay = shared.getString("last_daily_update_day", null)
                if (lastDay != dayKey) {
                    val gentle = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
                        .setSmallIcon(R.drawable.ic_notification_small)
                        .setContentTitle("Update Harian")
                        .setContentText("Cek budget hari ini biar tetap on track.")
                        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                        .setAutoCancel(true)
                        .build()
                    NotificationManagerCompat.from(applicationContext).notify(11002, gentle)
                    shared.edit().putString("last_daily_update_day", dayKey).apply()
                }
            }
        }

        return Result.success()
    }

    private fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Daily Update",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Pengingat harian dan fixed expense jatuh tempo"
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    private fun hasNotificationPermission(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        return ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    private fun actionPendingIntent(
        action: String,
        fixedExpenseId: String,
        notificationId: Int,
        requestCode: Int,
    ): android.app.PendingIntent {
        val intent = Intent(applicationContext, ReminderActionReceiver::class.java).apply {
            this.action = action
            putExtra(ReminderActionReceiver.EXTRA_FIXED_EXPENSE_ID, fixedExpenseId)
            putExtra(ReminderActionReceiver.EXTRA_NOTIFICATION_ID, notificationId)
        }
        return PendingIntent.getBroadcast(
            applicationContext,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}

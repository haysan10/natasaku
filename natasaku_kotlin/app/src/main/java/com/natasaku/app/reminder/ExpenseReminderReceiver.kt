package com.natasaku.app.reminder

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.RemoteInput
import androidx.core.content.ContextCompat
import com.natasaku.app.MainActivity
import com.natasaku.app.R
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId

class ExpenseReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val appContext = context.applicationContext
        val store = ExpenseReminderStore(appContext)
        val scheduler = ExpenseReminderScheduler(appContext)

        when (intent.action) {
            ACTION_CHECK_DAILY_EXPENSE -> {
                handleDailyReminderCheck(appContext, store)
                scheduler.scheduleNext()
            }

            ACTION_QUICK_ADD_INPUT -> {
                val results = RemoteInput.getResultsFromIntent(intent)
                val replyText = results?.getCharSequence(KEY_QUICK_INPUT)?.toString().orEmpty()
                handleQuickAdd(appContext, store, replyText)
                scheduler.scheduleNext()
            }

            ACTION_SNOOZE_2H -> {
                val next = LocalDateTime.now().plusHours(2)
                    .atZone(ZoneId.systemDefault())
                    .toInstant()
                    .toEpochMilli()
                store.setMuteUntilMs(next)
                NotificationManagerCompat.from(appContext).cancel(NOTIFICATION_ID)
                scheduler.scheduleNext()
            }

            ACTION_MARK_DONE_TODAY -> {
                store.markExpenseForDate(LocalDate.now())
                NotificationManagerCompat.from(appContext).cancel(NOTIFICATION_ID)
                scheduler.scheduleNext()
            }

            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                scheduler.scheduleNext()
            }
        }
    }

    private fun handleDailyReminderCheck(context: Context, store: ExpenseReminderStore) {
        if (!hasNotificationPermission(context)) return

        val now = LocalDateTime.now()
        val slotKey = "${LocalDate.now()}-${now.hour}"

        if (store.hasExpenseForDate(LocalDate.now())) return
        if (store.getMuteUntilMs() > System.currentTimeMillis()) return
        if (store.wasPromptedInSlot(slotKey)) return

        showReminderNotification(context)
        store.markPromptedSlot(slotKey)
    }

    private fun handleQuickAdd(context: Context, store: ExpenseReminderStore, replyText: String) {
        if (replyText.isBlank()) return

        val parsed = QuickExpenseInputParser.parseToPendingTransaction(replyText)
        if (parsed == null) {
        showResultNotification(
            context,
            title = "Format belum dikenali",
            body = "Contoh: Rp25rb makan siang atau pemasukan 500000 freelance",
        )
            return
        }

        store.enqueuePendingTransaction(parsed)
        if (parsed.type == "Pengeluaran") {
            store.markExpenseForDate(LocalDate.now())
        }

        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
        showResultNotification(
            context,
            title = "Transaksi tersimpan",
            body = "${parsed.type} ${parsed.currencyCode} ${parsed.amount} tersimpan. Buka app untuk cek detail.",
        )
    }

    private fun showReminderNotification(context: Context) {
        createChannel(context)

        val openIntent = PendingIntent.getActivity(
            context,
            44010,
            Intent(context, MainActivity::class.java).apply {
                action = ACTION_OPEN_QUICK_INPUT
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra(EXTRA_OPEN_QUICK_INPUT, true)
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val quickInputIntent = PendingIntent.getBroadcast(
            context,
            44011,
            Intent(context, ExpenseReminderReceiver::class.java).apply {
                action = ACTION_QUICK_ADD_INPUT
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
        )

        val remoteInput = RemoteInput.Builder(KEY_QUICK_INPUT)
            .setLabel("Contoh: Rp25rb makan siang")
            .build()

        val quickAction = NotificationCompat.Action.Builder(
            0,
            "Catat Cepat",
            quickInputIntent,
        )
            .addRemoteInput(remoteInput)
            .setAllowGeneratedReplies(true)
            .build()

        val snoozeIntent = PendingIntent.getBroadcast(
            context,
            44012,
            Intent(context, ExpenseReminderReceiver::class.java).apply {
                action = ACTION_SNOOZE_2H
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val doneIntent = PendingIntent.getBroadcast(
            context,
            44013,
            Intent(context, ExpenseReminderReceiver::class.java).apply {
                action = ACTION_MARK_DONE_TODAY
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_small)
            .setContentTitle("Belum ada catatan pengeluaran hari ini")
            .setContentText("Yuk catat cepat biar jatah harian tetap akurat.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(openIntent)
            .addAction(quickAction)
            .addAction(0, "Buka Form", openIntent)
            .addAction(0, "Tunda 2 Jam", snoozeIntent)
            .addAction(0, "Sudah Dicatat", doneIntent)
            .build()

        NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
    }

    private fun showResultNotification(context: Context, title: String, body: String) {
        if (!hasNotificationPermission(context)) return
        createChannel(context)

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_small)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat.from(context).notify(NOTIFICATION_RESULT_ID, notification)
    }

    private fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Pengingat Catat Pengeluaran",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Pengingat pengeluaran harian dengan catat cepat"
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    private fun hasNotificationPermission(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        return ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    companion object {
        const val ACTION_CHECK_DAILY_EXPENSE = "com.natasaku.app.reminder.ACTION_CHECK_DAILY_EXPENSE"
        const val ACTION_QUICK_ADD_INPUT = "com.natasaku.app.reminder.ACTION_QUICK_ADD_INPUT"
        const val ACTION_SNOOZE_2H = "com.natasaku.app.reminder.ACTION_SNOOZE_2H"
        const val ACTION_MARK_DONE_TODAY = "com.natasaku.app.reminder.ACTION_MARK_DONE_TODAY"
        const val ACTION_OPEN_QUICK_INPUT = "com.natasaku.app.reminder.ACTION_OPEN_QUICK_INPUT"

        const val EXTRA_OPEN_QUICK_INPUT = "extra_open_quick_input"

        private const val CHANNEL_ID = "expense_reminder_channel"
        private const val KEY_QUICK_INPUT = "quick_input_text"
        private const val NOTIFICATION_ID = 44001
        private const val NOTIFICATION_RESULT_ID = 44002
    }
}

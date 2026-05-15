package com.natasaku.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

object QuickToolsNotificationManager {
    private const val channelName = "NataSaku Quick Tools"

    fun showOrUpdate(context: Context, state: QuickToolsState = QuickToolsStateStore.load(context)) {
        if (!QuickToolsStateStore.isNotificationEnabled(context)) {
            cancel(context)
            return
        }

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        ensureChannel(manager)

        val contentIntent = PendingIntent.getActivity(
            context,
            8000,
            Intent(context, MainActivity::class.java).apply {
                putExtra(QuickToolsContract.intentActionKey, QuickToolsContract.actionOpen)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val action10kIntent = broadcastIntent(
            context,
            8101,
            QuickToolsContract.receiverActionQuickExpense10k
        )
        val action50kIntent = broadcastIntent(
            context,
            8102,
            QuickToolsContract.receiverActionQuickExpense50k
        )
        val actionCheckIntent = broadcastIntent(
            context,
            8103,
            QuickToolsContract.receiverActionCheck
        )

        val notification = NotificationCompat.Builder(context, QuickToolsContract.notificationChannelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("NataSaku • Batas Aman ${state.dailySafeBudgetText}")
            .setContentText("Sisa ${state.remainingFundText} · ${state.dailyStatus}")
            .setStyle(
                NotificationCompat.BigTextStyle().bigText(
                    "Hari ini keluar ${state.todayExpenseText}. ${state.advice}"
                )
            )
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(0, "+10k", action10kIntent)
            .addAction(0, "+50k", action50kIntent)
            .addAction(0, "Cek", actionCheckIntent)
            .build()

        manager.notify(QuickToolsContract.notificationId, notification)
    }

    fun showQuickExpenseReceipt(context: Context, amount: Long, state: QuickToolsState) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        ensureChannel(manager)

        val receipt = NotificationCompat.Builder(context, QuickToolsContract.notificationChannelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Catat cepat tersimpan")
            .setContentText("+Rp${formatRupiahNumber(amount)} · Sisa ${state.remainingFundText}")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setTimeoutAfter(3500)
            .build()

        manager.notify(QuickToolsContract.receiptNotificationId, receipt)
    }

    fun cancel(context: Context) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(QuickToolsContract.notificationId)
    }

    private fun broadcastIntent(context: Context, requestCode: Int, action: String): PendingIntent {
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            Intent(context, QuickToolsActionReceiver::class.java).apply {
                this.action = action
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun ensureChannel(manager: NotificationManager) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(
            QuickToolsContract.notificationChannelId,
            channelName,
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Quick tools NataSaku yang selalu tampil"
            setShowBadge(false)
            setSound(null, null)
            enableVibration(false)
        }

        manager.createNotificationChannel(channel)
    }

    private fun formatRupiahNumber(amount: Long): String {
        val raw = String.format("%,d", amount)
        return raw.replace(',', '.')
    }
}

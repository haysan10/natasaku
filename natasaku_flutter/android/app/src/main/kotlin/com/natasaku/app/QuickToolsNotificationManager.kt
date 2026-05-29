package com.natasaku.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
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

        val actionCatatIntent = broadcastIntent(
            context,
            8104,
            QuickToolsContract.receiverActionQuickAdd
        )
        val actionCheckIntent = broadcastIntent(
            context,
            8103,
            QuickToolsContract.receiverActionCheck
        )
        val actionSimulasiIntent = broadcastIntent(
            context,
            8105,
            QuickToolsContract.receiverActionSimulasi
        )

        val collapsedView = android.widget.RemoteViews(context.packageName, R.layout.notification_natasaku_collapsed)
        collapsedView.setTextViewText(R.id.tv_main_value_collapsed, "${state.dailySafeBudgetText} masih aman hari ini")

        val remainingPercent = (100 - state.usagePercent).coerceIn(0, 100)
        
        val expandedView = android.widget.RemoteViews(context.packageName, R.layout.notification_natasaku_expanded)
        expandedView.setTextViewText(R.id.tv_main_value_expanded, "${state.dailySafeBudgetText} masih aman hari ini")
        expandedView.setTextViewText(R.id.tv_summary_expanded, "Keluar ${state.todayExpenseText} · Besok aman ${state.tomorrowBudgetText}")
        expandedView.setProgressBar(R.id.pb_progress_expanded, 100, remainingPercent, false)
        expandedView.setTextViewText(R.id.tv_progress_text, "$remainingPercent% jatah hari ini masih tersedia")
        expandedView.setTextViewText(R.id.tv_advice, state.advice)

        expandedView.setOnClickPendingIntent(R.id.btn_catat, actionCatatIntent)
        expandedView.setOnClickPendingIntent(R.id.btn_cek_jatah, actionCheckIntent)
        expandedView.setOnClickPendingIntent(R.id.btn_simulasi, actionSimulasiIntent)

        val notification = NotificationCompat.Builder(context, QuickToolsContract.notificationChannelId)
            .setSmallIcon(R.drawable.ic_notification)
            .setCustomContentView(collapsedView)
            .setCustomBigContentView(expandedView)
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setSilent(true)
            .setLocalOnly(true)
            .setColor(Color.parseColor("#0D9488"))
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        manager.notify(QuickToolsContract.notificationId, notification)
    }

    fun showQuickExpenseReceipt(context: Context, amount: Long, state: QuickToolsState) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        ensureChannel(manager)

        val receipt = NotificationCompat.Builder(context, QuickToolsContract.notificationChannelId)
            .setSmallIcon(R.drawable.ic_notification)
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

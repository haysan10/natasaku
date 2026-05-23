package com.natasaku.app.data.worker

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.natasaku.app.R
import com.natasaku.app.core.money.RupiahFormatter
import com.natasaku.app.data.local.database.DatabaseProvider
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.data.local.entity.ScheduledPaymentExecutionEntity
import com.natasaku.app.domain.model.ExecutionStatus
import com.natasaku.app.domain.model.ExpenseSource
import com.natasaku.app.domain.validation.ScheduleDueCalculator
import java.time.Instant
import java.time.LocalDate
import java.util.UUID
import kotlinx.coroutines.flow.first

class ScheduledPaymentWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result {
        val db = DatabaseProvider.get(applicationContext)
        val paymentDao = db.scheduledPaymentDao()
        val executionDao = db.scheduledPaymentExecutionDao()
        val periodDao = db.budgetPeriodDao()
        val transactionDao = db.expenseTransactionDao()

        val today = LocalDate.now()
        val activePeriod = periodDao.observeActivePeriod().first()
        val scheduled = paymentDao.getActiveNow()
        scheduled.forEach { payment ->
            if (!ScheduleDueCalculator.isScheduledPaymentDue(
                    startDate = payment.startDate,
                    endDate = payment.endDate,
                    frequency = payment.frequency,
                    dayOfMonth = payment.dayOfMonth,
                    customIntervalDays = payment.customIntervalDays,
                    targetDate = today,
                )
            ) {
                return@forEach
            }
            if (payment.lastExecutedDate == today || executionDao.countByDate(payment.id, today) > 0) {
                executionDao.upsert(
                    ScheduledPaymentExecutionEntity(
                        scheduledPaymentId = payment.id,
                        executedDate = today,
                        transactionId = "SKIPPED_DUPLICATE",
                        status = ExecutionStatus.SKIPPED_DUPLICATE,
                    ),
                )
                return@forEach
            }
            if (activePeriod == null || today.isBefore(activePeriod.startDate) || today.isAfter(activePeriod.endDate)) {
                executionDao.upsert(
                    ScheduledPaymentExecutionEntity(
                        scheduledPaymentId = payment.id,
                        executedDate = today,
                        transactionId = "SKIPPED_NO_ACTIVE_PERIOD",
                        status = ExecutionStatus.SKIPPED_NO_ACTIVE_PERIOD,
                    ),
                )
                paymentDao.updateLastExecutedDate(payment.id, today)
                return@forEach
            }

            val transactionId = UUID.randomUUID().toString()
            transactionDao.upsert(
                ExpenseTransactionEntity(
                    id = transactionId,
                    periodId = activePeriod.id,
                    amount = payment.amount,
                    category = mapCategory(payment.categoryId),
                    date = today,
                    note = payment.note ?: "Jadwal otomatis: ${payment.name}",
                    createdAt = Instant.now(),
                    updatedAt = Instant.now(),
                    deletedAt = null,
                    source = ExpenseSource.MANUAL,
                    fixedExpenseId = null,
                ),
            )
            executionDao.upsert(
                ScheduledPaymentExecutionEntity(
                    scheduledPaymentId = payment.id,
                    executedDate = today,
                    transactionId = transactionId,
                    status = ExecutionStatus.SUCCESS,
                ),
            )
            paymentDao.updateLastExecutedDate(payment.id, today)
            notifySuccess(payment.name, payment.amount)
        }
        return Result.success()
    }

    private fun notifySuccess(name: String, amount: Long) {
        val channelId = "scheduled_payment_channel"
        ensureChannel(channelId, "Jadwal Pembayaran Otomatis")
        val content = "💸 $name sebesar ${RupiahFormatter().format(amount)} sudah dicatat otomatis hari ini"
        val pendingIntent = PendingIntent.getActivity(
            applicationContext,
            0,
            Intent(Intent.ACTION_VIEW, Uri.parse("natasaku://riwayat")).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = NotificationCompat.Builder(applicationContext, channelId)
            .setSmallIcon(R.drawable.ic_notification_small)
            .setContentTitle("Jadwal Pembayaran Otomatis")
            .setContentText(content)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()
        NotificationManagerCompat.from(applicationContext).notify((System.currentTimeMillis() % 100000).toInt(), notification)
    }

    private fun ensureChannel(channelId: String, name: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(channelId) != null) return
        manager.createNotificationChannel(
            NotificationChannel(channelId, name, NotificationManager.IMPORTANCE_DEFAULT),
        )
    }

    private fun mapCategory(categoryId: Long): String {
        return when (categoryId) {
            1L -> "Kos"
            2L -> "Tagihan"
            3L -> "Transportasi"
            4L -> "Makan"
            else -> "Pengeluaran Terjadwal"
        }
    }
}

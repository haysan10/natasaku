package com.natasaku.app.data.worker

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.natasaku.app.R
import com.natasaku.app.core.money.RupiahFormatter
import com.natasaku.app.data.local.database.DatabaseProvider
import com.natasaku.app.data.local.entity.SavingAllocationEntity
import com.natasaku.app.data.local.entity.ScheduledSavingExecutionEntity
import com.natasaku.app.domain.validation.ScheduleDueCalculator
import java.time.Instant
import java.time.LocalDate
import java.util.UUID
import kotlinx.coroutines.flow.first

class ScheduledSavingWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {
    companion object {
        private const val STATUS_SUCCESS = "SUCCESS"
        private const val STATUS_SKIPPED_NO_ACTIVE_PERIOD = "SKIPPED_NO_ACTIVE_PERIOD"
        private const val STATUS_SKIPPED_DUPLICATE = "SKIPPED_DUPLICATE"
        private const val STATUS_SKIPPED_MANUAL_ALREADY_ALLOCATED = "SKIPPED_MANUAL_ALREADY_ALLOCATED"
        private const val STATUS_SKIPPED_TARGET_REACHED = "SKIPPED_TARGET_REACHED"
        private const val STATUS_SKIPPED_NO_TARGET = "SKIPPED_NO_TARGET"
    }

    override suspend fun doWork(): Result {
        val db = DatabaseProvider.get(applicationContext)
        val periodDao = db.budgetPeriodDao()
        val allocationDao = db.savingAllocationDao()
        val targetDao = db.savingTargetDao()
        val savingDao = db.scheduledSavingDao()
        val executionDao = db.scheduledSavingExecutionDao()

        val today = LocalDate.now()
        val scheduledSavings = savingDao.getActiveNow()
        val activePeriod = periodDao.observeActivePeriod().first()
        if (activePeriod == null) {
            scheduledSavings.forEach { scheduled ->
                if (ScheduleDueCalculator.isScheduledSavingDue(
                        startDate = scheduled.startDate,
                        endDate = scheduled.endDate,
                        frequency = scheduled.frequency,
                        dayOfMonth = scheduled.dayOfMonth,
                        dayOfWeek = scheduled.dayOfWeek,
                        targetDate = today,
                    )
                ) {
                    executionDao.upsert(
                        ScheduledSavingExecutionEntity(
                            scheduledSavingId = scheduled.id,
                            executedDate = today,
                            savingAllocationId = STATUS_SKIPPED_NO_ACTIVE_PERIOD,
                            amount = 0L,
                            status = STATUS_SKIPPED_NO_ACTIVE_PERIOD,
                        ),
                    )
                }
            }
            notifyInfo("Jadwal tabungan dilewati karena belum ada periode aktif.")
            return Result.success()
        }

        val existingAllocations = allocationDao.observeByPeriod(activePeriod.id).first()
        val manualAlreadyAllocatedToday = existingAllocations.any { it.date == today && !it.source.startsWith("AUTO_SCHEDULED") }
        val targets = targetDao.observeAll().first()

        scheduledSavings.forEach { scheduled ->
            if (!ScheduleDueCalculator.isScheduledSavingDue(
                    startDate = scheduled.startDate,
                    endDate = scheduled.endDate,
                    frequency = scheduled.frequency,
                    dayOfMonth = scheduled.dayOfMonth,
                    dayOfWeek = scheduled.dayOfWeek,
                    targetDate = today,
                )
            ) {
                return@forEach
            }
            if (scheduled.lastExecutedDate == today || executionDao.countByDate(scheduled.id, today) > 0) {
                executionDao.upsert(
                    ScheduledSavingExecutionEntity(
                        scheduledSavingId = scheduled.id,
                        executedDate = today,
                        savingAllocationId = STATUS_SKIPPED_DUPLICATE,
                        amount = 0L,
                        status = STATUS_SKIPPED_DUPLICATE,
                    ),
                )
                return@forEach
            }
            val target = targets.firstOrNull { it.id == scheduled.savingTargetId }
            if (target == null) {
                savingDao.updateActive(scheduled.id, false)
                executionDao.upsert(
                    ScheduledSavingExecutionEntity(
                        scheduledSavingId = scheduled.id,
                        executedDate = today,
                        savingAllocationId = STATUS_SKIPPED_NO_TARGET,
                        amount = 0L,
                        status = STATUS_SKIPPED_NO_TARGET,
                    ),
                )
                return@forEach
            }
            val collected = existingAllocations.filter { it.date >= activePeriod.startDate && it.date <= activePeriod.endDate }.sumOf { it.amount }
            if (collected >= target.targetAmount && target.targetAmount > 0L) {
                savingDao.updateActive(scheduled.id, false)
                executionDao.upsert(
                    ScheduledSavingExecutionEntity(
                        scheduledSavingId = scheduled.id,
                        executedDate = today,
                        savingAllocationId = STATUS_SKIPPED_TARGET_REACHED,
                        amount = 0L,
                        status = STATUS_SKIPPED_TARGET_REACHED,
                    ),
                )
                notifyInfo("🎉 Target tabungan ${scheduled.name} sudah tercapai! Jadwal dihentikan.")
                return@forEach
            }
            if (manualAlreadyAllocatedToday) {
                executionDao.upsert(
                    ScheduledSavingExecutionEntity(
                        scheduledSavingId = scheduled.id,
                        executedDate = today,
                        savingAllocationId = STATUS_SKIPPED_MANUAL_ALREADY_ALLOCATED,
                        amount = 0L,
                        status = STATUS_SKIPPED_MANUAL_ALREADY_ALLOCATED,
                    ),
                )
                savingDao.updateLastExecutedDate(scheduled.id, today)
                notifyInfo("Tabungan hari ini sudah dialokasikan manual, skip otomatis")
                return@forEach
            }

            val allocationId = UUID.randomUUID().toString()
            allocationDao.upsert(
                SavingAllocationEntity(
                    id = allocationId,
                    periodId = activePeriod.id,
                    amount = scheduled.amountPerExecution,
                    date = today,
                    source = "AUTO_SCHEDULED_SAVING",
                ),
            )
            executionDao.upsert(
                ScheduledSavingExecutionEntity(
                    scheduledSavingId = scheduled.id,
                    executedDate = today,
                    savingAllocationId = allocationId,
                    amount = scheduled.amountPerExecution,
                    status = STATUS_SUCCESS,
                ),
            )
            savingDao.updateLastExecutedDate(scheduled.id, today)
            notifyInfo("🎯 Tabungan ${scheduled.name} ${RupiahFormatter().format(scheduled.amountPerExecution)} berhasil dialokasikan otomatis")
        }
        return Result.success()
    }

    private fun notifyInfo(message: String) {
        val channelId = "scheduled_saving_channel"
        ensureChannel(channelId, "Jadwal Tabungan Otomatis")
        val notification = NotificationCompat.Builder(applicationContext, channelId)
            .setSmallIcon(R.drawable.ic_notification_small)
            .setContentTitle("Jadwal Tabungan Otomatis")
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .build()
        NotificationManagerCompat.from(applicationContext).notify((Instant.now().toEpochMilli() % 100000).toInt(), notification)
    }

    private fun ensureChannel(channelId: String, name: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(channelId) != null) return
        manager.createNotificationChannel(
            NotificationChannel(channelId, name, NotificationManager.IMPORTANCE_DEFAULT),
        )
    }
}

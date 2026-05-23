package com.natasaku.app

import android.app.Application
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.natasaku.app.data.local.database.DatabaseProvider
import com.natasaku.app.data.worker.ScheduledPaymentWorker
import com.natasaku.app.data.worker.ScheduledSavingWorker
import java.time.LocalDate
import java.util.concurrent.TimeUnit
import dagger.hilt.android.HiltAndroidApp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

@HiltAndroidApp
class NataSakuApplication : Application() {
    private val appScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onCreate() {
        super.onCreate()
        schedulePeriodicWorkers()
        runDataIntegrityChecks()
    }

    private fun schedulePeriodicWorkers() {
        val manager = WorkManager.getInstance(this)
        manager.enqueueUniquePeriodicWork(
            "scheduled_payment_worker",
            ExistingPeriodicWorkPolicy.KEEP,
            PeriodicWorkRequestBuilder<ScheduledPaymentWorker>(1, TimeUnit.DAYS)
                .setConstraints(Constraints.NONE)
                .build(),
        )
        manager.enqueueUniquePeriodicWork(
            "scheduled_saving_worker",
            ExistingPeriodicWorkPolicy.KEEP,
            PeriodicWorkRequestBuilder<ScheduledSavingWorker>(1, TimeUnit.DAYS)
                .setConstraints(Constraints.NONE)
                .build(),
        )
    }

    private fun runDataIntegrityChecks() {
        appScope.launch {
            val db = DatabaseProvider.get(this@NataSakuApplication)
            db.expenseTransactionDao().deleteCorruptedZeroAmount()
            db.budgetPeriodDao().deactivateExpiredActivePeriod(LocalDate.now())
        }
    }
}

package com.natasaku.app.reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat
import com.natasaku.app.data.local.database.DatabaseProvider
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.domain.model.ExpenseSource
import com.natasaku.app.domain.model.FixedExpenseStatus
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.util.UUID
import kotlin.concurrent.thread
import kotlinx.coroutines.runBlocking

class ReminderActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val fixedExpenseId = intent.getStringExtra(EXTRA_FIXED_EXPENSE_ID) ?: return
        val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, -1)
        val action = intent.action
        val appContext = context.applicationContext

        thread(start = true, name = "reminder-action") {
            runBlocking {
                val db = DatabaseProvider.get(appContext)
                val dao = db.fixedExpenseDao()
                val item = dao.getById(fixedExpenseId) ?: return@runBlocking

                when (action) {
                    ACTION_MARK_PAID -> {
                        dao.updatePaid(item.id, FixedExpenseStatus.PAID, Instant.now())
                        db.expenseTransactionDao().upsert(
                            ExpenseTransactionEntity(
                                id = UUID.randomUUID().toString(),
                                periodId = item.periodId,
                                amount = item.amount,
                                category = "Fixed Expense",
                                date = LocalDate.now(),
                                note = "Pembayaran: ${item.name}",
                                createdAt = Instant.now(),
                                updatedAt = Instant.now(),
                                deletedAt = null,
                                source = ExpenseSource.FIXED_EXPENSE,
                                fixedExpenseId = item.id,
                            ),
                        )
                    }

                    ACTION_SNOOZE_2H -> {
                        val now = java.time.ZonedDateTime.now()
                        val proposed = now.plusHours(2)
                        val next = if (proposed.toLocalTime().isAfter(LocalTime.of(18, 0))) {
                            proposed.plusDays(1).withHour(7).withMinute(0).withSecond(0).withNano(0)
                        } else proposed
                        dao.updateSnooze(item.id, FixedExpenseStatus.PENDING, next.toInstant())
                    }

                    ACTION_RESCHEDULE -> {
                        val tomorrowDueDay = LocalDate.now().plusDays(1).dayOfMonth
                        dao.reschedule(item.id, FixedExpenseStatus.PENDING, tomorrowDueDay)
                    }
                }
            }
        }

        if (notificationId != -1) {
            NotificationManagerCompat.from(appContext).cancel(notificationId)
        }
    }

    companion object {
        const val ACTION_MARK_PAID = "com.natasaku.app.reminder.ACTION_MARK_PAID"
        const val ACTION_SNOOZE_2H = "com.natasaku.app.reminder.ACTION_SNOOZE_2H"
        const val ACTION_RESCHEDULE = "com.natasaku.app.reminder.ACTION_RESCHEDULE"

        const val EXTRA_FIXED_EXPENSE_ID = "extra_fixed_expense_id"
        const val EXTRA_NOTIFICATION_ID = "extra_notification_id"
    }
}

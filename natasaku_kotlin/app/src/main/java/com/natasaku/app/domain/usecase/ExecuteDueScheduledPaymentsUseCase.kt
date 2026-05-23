package com.natasaku.app.domain.usecase

import com.natasaku.app.data.local.dao.ScheduledPaymentDao
import java.time.LocalDate

class ExecuteDueScheduledPaymentsUseCase(
    private val scheduledPaymentDao: ScheduledPaymentDao,
) {
    suspend operator fun invoke(today: LocalDate = LocalDate.now()): Int {
        return scheduledPaymentDao.getActiveNow().count {
            (it.lastExecutedDate == null || it.lastExecutedDate != today) &&
                !today.isBefore(it.startDate) &&
                (it.endDate == null || !today.isAfter(it.endDate))
        }
    }
}

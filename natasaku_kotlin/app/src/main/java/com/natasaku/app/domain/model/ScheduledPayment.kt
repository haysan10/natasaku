package com.natasaku.app.domain.model

import java.time.Instant
import java.time.LocalDate

data class ScheduledPayment(
    val id: Long = 0,
    val name: String,
    val amount: Long,
    val categoryId: Long,
    val dayOfMonth: Int,
    val frequency: PaymentFrequency,
    val customIntervalDays: Int? = null,
    val startDate: LocalDate,
    val endDate: LocalDate? = null,
    val isActive: Boolean = true,
    val note: String? = null,
    val lastExecutedDate: LocalDate? = null,
    val createdAt: Instant = Instant.now(),
)

enum class PaymentFrequency {
    WEEKLY,
    MONTHLY,
    CUSTOM_DAYS,
}

data class ScheduledPaymentExecution(
    val id: Long = 0,
    val scheduledPaymentId: Long,
    val executedDate: LocalDate,
    val transactionId: String,
    val status: ExecutionStatus,
)

enum class ExecutionStatus {
    SUCCESS,
    SKIPPED_NO_ACTIVE_PERIOD,
    SKIPPED_DUPLICATE,
}

package com.natasaku.app.domain.model

import java.time.Instant
import java.time.LocalDate

data class ScheduledSaving(
    val id: Long = 0,
    val savingTargetId: String,
    val name: String,
    val amountPerExecution: Long,
    val frequency: SavingFrequency,
    val dayOfMonth: Int? = null,
    val dayOfWeek: Int? = null,
    val startDate: LocalDate,
    val endDate: LocalDate? = null,
    val isActive: Boolean = true,
    val lastExecutedDate: LocalDate? = null,
    val createdAt: Instant = Instant.now(),
)

enum class SavingFrequency {
    DAILY,
    WEEKLY,
    MONTHLY,
}

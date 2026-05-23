package com.natasaku.app.domain.validation

import com.natasaku.app.domain.model.PaymentFrequency
import com.natasaku.app.domain.model.SavingFrequency
import java.time.LocalDate
import java.time.temporal.ChronoUnit

object ScheduleDueCalculator {
    fun isScheduledPaymentDue(
        startDate: LocalDate,
        endDate: LocalDate?,
        frequency: PaymentFrequency,
        dayOfMonth: Int,
        customIntervalDays: Int?,
        targetDate: LocalDate,
    ): Boolean {
        if (targetDate.isBefore(startDate)) return false
        if (endDate != null && targetDate.isAfter(endDate)) return false
        return when (frequency) {
            PaymentFrequency.WEEKLY -> ChronoUnit.DAYS.between(startDate, targetDate) % 7L == 0L
            PaymentFrequency.MONTHLY -> {
                val maxDay = targetDate.lengthOfMonth()
                val targetDay = when {
                    dayOfMonth == -1 -> maxDay
                    else -> dayOfMonth.coerceIn(1, 31).coerceAtMost(maxDay)
                }
                targetDate.dayOfMonth == targetDay
            }
            PaymentFrequency.CUSTOM_DAYS -> {
                val interval = (customIntervalDays ?: 1).coerceIn(1, 365)
                ChronoUnit.DAYS.between(startDate, targetDate) % interval.toLong() == 0L
            }
        }
    }

    fun nextScheduledPaymentExecutionDate(
        startDate: LocalDate,
        endDate: LocalDate?,
        frequency: PaymentFrequency,
        dayOfMonth: Int,
        customIntervalDays: Int?,
        lastExecutedDate: LocalDate?,
        today: LocalDate,
    ): LocalDate? {
        if (endDate != null && today.isAfter(endDate)) return null
        val searchStart = maxOf(today, startDate)
        val seed = lastExecutedDate ?: startDate

        return when (frequency) {
            PaymentFrequency.WEEKLY -> {
                val baseline = if (seed.isAfter(searchStart)) seed else searchStart
                if (isScheduledPaymentDue(startDate, endDate, frequency, dayOfMonth, customIntervalDays, baseline)) {
                    baseline
                } else {
                    baseline.plusDays(1).datesUntil(baseline.plusDays(8))
                        .firstOrNull { isScheduledPaymentDue(startDate, endDate, frequency, dayOfMonth, customIntervalDays, it) }
                }
            }
            PaymentFrequency.MONTHLY -> {
                var cursor = LocalDate.of(searchStart.year, searchStart.month, 1)
                repeat(24) {
                    val maxDay = cursor.lengthOfMonth()
                    val scheduledDay = when {
                        dayOfMonth == -1 -> maxDay
                        else -> dayOfMonth.coerceIn(1, 31).coerceAtMost(maxDay)
                    }
                    val candidate = cursor.withDayOfMonth(scheduledDay)
                    if (!candidate.isBefore(searchStart) && !candidate.isBefore(startDate) && (endDate == null || !candidate.isAfter(endDate))) {
                        return candidate
                    }
                    cursor = cursor.plusMonths(1)
                }
                null
            }
            PaymentFrequency.CUSTOM_DAYS -> {
                val interval = (customIntervalDays ?: 1).coerceIn(1, 365).toLong()
                val from = maxOf(seed, startDate)
                if (!from.isBefore(searchStart)) {
                    if (endDate != null && from.isAfter(endDate)) null else from
                } else {
                    val elapsed = ChronoUnit.DAYS.between(from, searchStart)
                    val mod = elapsed % interval
                    val delta = if (mod == 0L) 0L else interval - mod
                    val next = searchStart.plusDays(delta)
                    if (endDate != null && next.isAfter(endDate)) null else next
                }
            }
        }
    }

    fun isScheduledSavingDue(
        startDate: LocalDate,
        endDate: LocalDate?,
        frequency: SavingFrequency,
        dayOfMonth: Int?,
        dayOfWeek: Int?,
        targetDate: LocalDate,
    ): Boolean {
        if (targetDate.isBefore(startDate)) return false
        if (endDate != null && targetDate.isAfter(endDate)) return false
        return when (frequency) {
            SavingFrequency.DAILY -> true
            SavingFrequency.WEEKLY -> {
                if (dayOfWeek == null) {
                    ChronoUnit.DAYS.between(startDate, targetDate) % 7L == 0L
                } else {
                    targetDate.dayOfWeek.value == dayOfWeek.coerceIn(1, 7)
                }
            }
            SavingFrequency.MONTHLY -> {
                val targetDay = (dayOfMonth ?: 1).coerceIn(1, 28)
                targetDate.dayOfMonth == targetDay
            }
        }
    }
}

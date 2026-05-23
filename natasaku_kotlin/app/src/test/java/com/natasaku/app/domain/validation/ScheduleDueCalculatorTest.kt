package com.natasaku.app.domain.validation

import com.natasaku.app.domain.model.PaymentFrequency
import com.natasaku.app.domain.model.SavingFrequency
import java.time.LocalDate
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ScheduleDueCalculatorTest {
    @Test
    fun monthlyPayment_dueOnClampedDayForShortMonth() {
        val date = LocalDate.of(2026, 2, 28)
        val due = ScheduleDueCalculator.isScheduledPaymentDue(
            startDate = LocalDate.of(2026, 1, 1),
            endDate = null,
            frequency = PaymentFrequency.MONTHLY,
            dayOfMonth = 31,
            customIntervalDays = null,
            targetDate = date,
        )
        assertTrue(due)
    }

    @Test
    fun monthlyPayment_minusOneMeansLastDay() {
        val due = ScheduleDueCalculator.isScheduledPaymentDue(
            startDate = LocalDate.of(2026, 1, 1),
            endDate = null,
            frequency = PaymentFrequency.MONTHLY,
            dayOfMonth = -1,
            customIntervalDays = null,
            targetDate = LocalDate.of(2026, 4, 30),
        )
        assertTrue(due)
    }

    @Test
    fun weeklySaving_dueByDayOfWeek() {
        val monday = LocalDate.of(2026, 5, 25)
        val due = ScheduleDueCalculator.isScheduledSavingDue(
            startDate = LocalDate.of(2026, 5, 1),
            endDate = null,
            frequency = SavingFrequency.WEEKLY,
            dayOfMonth = null,
            dayOfWeek = 1,
            targetDate = monday,
        )
        assertTrue(due)
    }

    @Test
    fun customDays_notDueWhenBeforeStart() {
        val due = ScheduleDueCalculator.isScheduledPaymentDue(
            startDate = LocalDate.of(2026, 6, 1),
            endDate = null,
            frequency = PaymentFrequency.CUSTOM_DAYS,
            dayOfMonth = 1,
            customIntervalDays = 3,
            targetDate = LocalDate.of(2026, 5, 31),
        )
        assertFalse(due)
    }

    @Test
    fun nextScheduledPaymentDate_respectsEndDate() {
        val next = ScheduleDueCalculator.nextScheduledPaymentExecutionDate(
            startDate = LocalDate.of(2026, 1, 1),
            endDate = LocalDate.of(2026, 5, 1),
            frequency = PaymentFrequency.MONTHLY,
            dayOfMonth = 1,
            customIntervalDays = null,
            lastExecutedDate = LocalDate.of(2026, 5, 1),
            today = LocalDate.of(2026, 5, 23),
        )
        assertEquals(null, next)
    }
}

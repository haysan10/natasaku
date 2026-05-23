package com.natasaku.app.data.local.database

import androidx.room.TypeConverter
import com.natasaku.app.domain.model.ExpenseSource
import com.natasaku.app.domain.model.FixedExpenseStatus
import com.natasaku.app.domain.model.PaymentFrequency
import com.natasaku.app.domain.model.ExecutionStatus
import com.natasaku.app.domain.model.SavingFrequency
import java.time.Instant
import java.time.LocalDate

class RoomConverters {
    @TypeConverter
    fun localDateToString(value: LocalDate?): String? = value?.toString()

    @TypeConverter
    fun stringToLocalDate(value: String?): LocalDate? = value?.let(LocalDate::parse)

    @TypeConverter
    fun instantToEpochMillis(value: Instant?): Long? = value?.toEpochMilli()

    @TypeConverter
    fun epochMillisToInstant(value: Long?): Instant? = value?.let(Instant::ofEpochMilli)

    @TypeConverter
    fun fixedExpenseStatusToString(value: FixedExpenseStatus?): String? = value?.name

    @TypeConverter
    fun stringToFixedExpenseStatus(value: String?): FixedExpenseStatus? =
        value?.let { runCatching { FixedExpenseStatus.valueOf(it) }.getOrNull() }

    @TypeConverter
    fun expenseSourceToString(value: ExpenseSource?): String? = value?.name

    @TypeConverter
    fun stringToExpenseSource(value: String?): ExpenseSource? =
        value?.let { runCatching { ExpenseSource.valueOf(it) }.getOrNull() }

    @TypeConverter
    fun paymentFrequencyToString(value: PaymentFrequency?): String? = value?.name

    @TypeConverter
    fun stringToPaymentFrequency(value: String?): PaymentFrequency? =
        value?.let { runCatching { PaymentFrequency.valueOf(it) }.getOrNull() }

    @TypeConverter
    fun executionStatusToString(value: ExecutionStatus?): String? = value?.name

    @TypeConverter
    fun stringToExecutionStatus(value: String?): ExecutionStatus? =
        value?.let { runCatching { ExecutionStatus.valueOf(it) }.getOrNull() }

    @TypeConverter
    fun savingFrequencyToString(value: SavingFrequency?): String? = value?.name

    @TypeConverter
    fun stringToSavingFrequency(value: String?): SavingFrequency? =
        value?.let { runCatching { SavingFrequency.valueOf(it) }.getOrNull() }
}

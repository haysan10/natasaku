package com.natasaku.app.data.local.database

import androidx.room.TypeConverter
import com.natasaku.app.domain.model.ExpenseSource
import com.natasaku.app.domain.model.FixedExpenseStatus
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
}

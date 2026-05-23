package com.natasaku.app.domain.model

import java.time.LocalDate
import java.time.Year
import java.time.YearMonth

enum class ReportGranularity {
    DAILY,
    WEEKLY,
    MONTHLY,
    YEARLY,
    BY_PERIOD,
}

data class ReportFilter(
    val granularity: ReportGranularity,
    val targetDate: LocalDate? = null,
    val weekStartDate: LocalDate? = null,
    val month: YearMonth? = null,
    val year: Year? = null,
    val periodId: String? = null,
    val periodStartDate: LocalDate? = null,
    val periodEndDate: LocalDate? = null,
)

sealed interface ReportState {
    data object Loading : ReportState
    data class Success(val report: UnifiedReport) : ReportState
    data class Error(val message: String) : ReportState
}

data class UnifiedReport(
    val filter: ReportFilter,
    val title: String,
    val periodLabel: String,
    val totalIncome: Long,
    val totalFixedExpense: Long,
    val totalSavingAllocated: Long,
    val totalSpent: Long,
    val flexibleBudget: Long,
    val remainingBudget: Long,
    val averageDailySpend: Long,
    val highestSpendDay: LocalDate?,
    val lowestSpendDay: LocalDate?,
    val overbudgetDaysCount: Int,
    val categoryBreakdown: List<CategorySpend>,
    val dailySpendData: List<DailySpend>,
    val transactions: List<ExpenseTransaction>,
    val scheduledPaymentsExecuted: List<ScheduledPaymentExecution>,
    val recommendation: String,
)

data class CategorySpend(
    val categoryId: Long,
    val categoryName: String,
    val categoryIcon: String,
    val totalAmount: Long,
    val transactionCount: Int,
    val percentage: Float,
)

data class DailySpend(
    val date: LocalDate,
    val amount: Long,
    val status: DailyStatus,
)

enum class DailyStatus {
    AMAN,
    WASPADA,
    MELEWATI_BATAS,
}

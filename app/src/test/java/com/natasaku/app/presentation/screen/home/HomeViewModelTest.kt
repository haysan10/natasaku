package com.natasaku.app.presentation.screen.home

import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.data.local.entity.FixedExpenseEntity
import com.natasaku.app.data.local.entity.IncomeSourceEntity
import com.natasaku.app.data.local.entity.SavingTargetEntity
import com.natasaku.app.domain.calculator.BudgetCalculator
import com.natasaku.app.domain.calculator.DailyBudgetCalculator
import com.natasaku.app.domain.model.FixedExpenseStatus
import com.natasaku.app.testutil.MainDispatcherRule
import java.time.Instant
import java.time.LocalDate
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class HomeViewModelTest {
    @get:Rule val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun saveExpense_invalidAmount_setsError() {
        val vm = createVm()
        vm.onEvent(HomeUiEvent.SaveExpense(0, "Makan", null))
        assertTrue(vm.uiState.value.addExpenseError?.isNotBlank() == true)
    }

    @Test
    fun loadDashboard_calculatesDailyAllowance() = runTest {
        val vm = createVm()
        vm.onEvent(HomeUiEvent.Load)
        advanceUntilIdle()
        assertEquals(50_000, vm.uiState.value.dailyAllowance)
    }

    private fun createVm(): HomeViewModel {
        val now = Instant.now()
        val period = BudgetPeriodEntity("p1", "Mei", LocalDate.now().minusDays(15), LocalDate.now().plusDays(14), true, now, now)

        val budgetDao = object : BudgetPeriodDao {
            override suspend fun upsert(period: BudgetPeriodEntity) {}
            override suspend fun upsertAll(periods: List<BudgetPeriodEntity>) {}
            override suspend fun clearActive() {}
            override fun observeActivePeriod(): Flow<BudgetPeriodEntity?> = MutableStateFlow(period)
            override fun observeAll(): Flow<List<BudgetPeriodEntity>> = flowOf(listOf(period))
        }

        val txDao = object : ExpenseTransactionDao {
            private val data = mutableListOf<ExpenseTransactionEntity>()
            override suspend fun upsert(transaction: ExpenseTransactionEntity) { data.add(transaction) }
            override fun observeByPeriod(periodId: String): Flow<List<ExpenseTransactionEntity>> = MutableStateFlow(data)
            override fun observeByPeriodAndQuery(periodId: String, query: String): Flow<List<ExpenseTransactionEntity>> = MutableStateFlow(data)
            override suspend fun softDelete(id: String, deletedAt: Instant) {}
            override suspend fun upsertAll(items: List<ExpenseTransactionEntity>) {}
            override fun observeAll(): Flow<List<ExpenseTransactionEntity>> = flowOf(data)
        }

        val incomeDao = object : IncomeSourceDao {
            override suspend fun upsertAll(items: List<IncomeSourceEntity>) {}
            override fun observeByPeriod(periodId: String): Flow<List<IncomeSourceEntity>> = MutableStateFlow(listOf(IncomeSourceEntity("i1", "p1", "Gaji", 3_000_000)))
            override fun observeAll(): Flow<List<IncomeSourceEntity>> = flowOf(listOf(IncomeSourceEntity("i1", "p1", "Gaji", 3_000_000)))
        }

        val fixedDao = object : FixedExpenseDao {
            private val fixed = listOf(
                FixedExpenseEntity("f1", "p1", "Kos", 1_000_000),
                FixedExpenseEntity("f2", "p1", "Makan", 500_000),
            )
            override suspend fun upsertAll(items: List<FixedExpenseEntity>) {}
            override suspend fun upsert(item: FixedExpenseEntity) {}
            override fun observeByPeriod(periodId: String): Flow<List<FixedExpenseEntity>> = MutableStateFlow(fixed)
            override fun observeAll(): Flow<List<FixedExpenseEntity>> = flowOf(fixed)
            override suspend fun getById(id: String): FixedExpenseEntity? = fixed.firstOrNull { it.id == id }
            override suspend fun updatePaid(id: String, status: FixedExpenseStatus, paidAt: Instant) {}
            override suspend fun updateSnooze(id: String, status: FixedExpenseStatus, snoozedUntilTs: Instant) {}
            override suspend fun reschedule(id: String, status: FixedExpenseStatus, dueDay: Int) {}
            override suspend fun updateStatus(id: String, status: FixedExpenseStatus) {}
        }

        val savingDao = object : SavingTargetDao {
            override suspend fun upsert(target: SavingTargetEntity) {}
            override suspend fun upsertAll(items: List<SavingTargetEntity>) {}
            override fun observeByPeriod(periodId: String): Flow<SavingTargetEntity?> = MutableStateFlow(SavingTargetEntity("s1", "p1", 0))
            override fun observeAll(): Flow<List<SavingTargetEntity>> = flowOf(listOf(SavingTargetEntity("s1", "p1", 0)))
        }

        return HomeViewModel(
            budgetPeriodDao = budgetDao,
            transactionDao = txDao,
            incomeSourceDao = incomeDao,
            fixedExpenseDao = fixedDao,
            savingTargetDao = savingDao,
            budgetCalculator = BudgetCalculator(),
            dailyBudgetCalculator = DailyBudgetCalculator(),
        )
    }
}

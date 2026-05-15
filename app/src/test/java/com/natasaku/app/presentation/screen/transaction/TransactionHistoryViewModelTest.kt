package com.natasaku.app.presentation.screen.transaction

import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
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
class TransactionHistoryViewModelTest {
    @get:Rule val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun search_and_filter_update_total_correctly() = runTest {
        val vm = createVm()
        vm.onEvent(TransactionHistoryUiEvent.Load)
        advanceUntilIdle()
        assertEquals(30_000, vm.uiState.value.totalFilteredSpending)

        vm.onEvent(TransactionHistoryUiEvent.UpdateQuery("makan"))
        advanceUntilIdle()
        assertEquals(10_000, vm.uiState.value.totalFilteredSpending)

        vm.onEvent(TransactionHistoryUiEvent.UpdateQuery(""))
        vm.onEvent(TransactionHistoryUiEvent.SelectCategory("Transport"))
        advanceUntilIdle()
        assertEquals(20_000, vm.uiState.value.totalFilteredSpending)
    }

    @Test
    fun confirmDelete_softDeletes_from_default_list() = runTest {
        val vm = createVm()
        vm.onEvent(TransactionHistoryUiEvent.Load)
        advanceUntilIdle()
        assertEquals(2, vm.uiState.value.grouped.sumOf { it.items.size })

        vm.onEvent(TransactionHistoryUiEvent.ConfirmDelete("t1"))
        advanceUntilIdle()
        assertEquals(1, vm.uiState.value.grouped.sumOf { it.items.size })
    }

    private fun createVm(): TransactionHistoryViewModel {
        val now = Instant.now()
        val periodFlow = MutableStateFlow(
            BudgetPeriodEntity("p1", "Mei", LocalDate.now().minusDays(3), LocalDate.now().plusDays(3), true, now, now),
        )
        val txFlow = MutableStateFlow(
            listOf(
                ExpenseTransactionEntity("t1", "p1", 10_000, "Makan", LocalDate.now(), "siang", now, now, null),
                ExpenseTransactionEntity("t2", "p1", 20_000, "Transport", LocalDate.now().minusDays(1), "ojek", now, now, null),
            ),
        )

        val budgetDao = object : BudgetPeriodDao {
            override suspend fun upsert(period: BudgetPeriodEntity) {}
            override suspend fun upsertAll(periods: List<BudgetPeriodEntity>) {}
            override suspend fun clearActive() {}
            override fun observeActivePeriod(): Flow<BudgetPeriodEntity?> = periodFlow
            override fun observeAll(): Flow<List<BudgetPeriodEntity>> = flowOf(listOf(periodFlow.value))
        }

        val txDao = object : ExpenseTransactionDao {
            override suspend fun upsert(transaction: ExpenseTransactionEntity) {
                txFlow.value = txFlow.value.filterNot { it.id == transaction.id } + transaction
            }

            override fun observeByPeriod(periodId: String): Flow<List<ExpenseTransactionEntity>> =
                MutableStateFlow(txFlow.value.filter { it.periodId == periodId && it.deletedAt == null })

            override fun observeByPeriodAndQuery(periodId: String, query: String): Flow<List<ExpenseTransactionEntity>> =
                MutableStateFlow(txFlow.value.filter { it.periodId == periodId && it.deletedAt == null })

            override suspend fun softDelete(id: String, deletedAt: Instant) {
                txFlow.value = txFlow.value.map { if (it.id == id) it.copy(deletedAt = deletedAt) else it }
            }

            override suspend fun upsertAll(items: List<ExpenseTransactionEntity>) {}
            override fun observeAll(): Flow<List<ExpenseTransactionEntity>> = flowOf(txFlow.value)
        }

        return TransactionHistoryViewModel(budgetDao, txDao)
    }
}

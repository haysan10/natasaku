package com.natasaku.app.presentation.screen.saving

import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import com.natasaku.app.data.local.entity.DailyBudgetSnapshotEntity
import com.natasaku.app.data.local.entity.SavingAllocationEntity
import com.natasaku.app.data.local.entity.SavingTargetEntity
import com.natasaku.app.domain.calculator.LeftoverAllocationCalculator
import com.natasaku.app.domain.model.LeftoverAllocationType
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
import org.junit.Assert.assertFalse
import org.junit.Rule
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class SavingViewModelTest {
    @get:Rule val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun allocate_only_once_per_day() = runTest {
        val env = createEnv(hasTarget = true)
        val vm = env.vm
        vm.onEvent(SavingUiEvent.Load)
        advanceUntilIdle()
        vm.onEvent(SavingUiEvent.AllocateLeftover(LeftoverAllocationType.SAVING))
        advanceUntilIdle()
        vm.onEvent(SavingUiEvent.AllocateLeftover(LeftoverAllocationType.SAVING))
        advanceUntilIdle()

        assertEquals(1, env.allocations.value.size)
        assertFalse(vm.uiState.value.showLeftoverDialog)
    }

    @Test
    fun allocate_to_saving_without_target_is_safe() = runTest {
        val env = createEnv(hasTarget = false)
        val vm = env.vm
        vm.onEvent(SavingUiEvent.Load)
        advanceUntilIdle()
        vm.onEvent(SavingUiEvent.AllocateLeftover(LeftoverAllocationType.SAVING))
        advanceUntilIdle()

        assertEquals(1, env.allocations.value.size)
        assertEquals(0L, env.allocations.value.first().amount)
        assertEquals("SAVING_SKIPPED_NO_TARGET", env.allocations.value.first().source)
    }

    private data class Env(
        val vm: SavingViewModel,
        val allocations: MutableStateFlow<List<SavingAllocationEntity>>,
    )

    private fun createEnv(hasTarget: Boolean): Env {
        val now = Instant.now()
        val today = LocalDate.now()
        val period = BudgetPeriodEntity("p1", "Mei", today.minusDays(5), today.plusDays(5), true, now, now)
        val allocations = MutableStateFlow<List<SavingAllocationEntity>>(emptyList())

        val budgetDao = object : BudgetPeriodDao {
            override suspend fun upsert(period: BudgetPeriodEntity) {}
            override suspend fun upsertAll(periods: List<BudgetPeriodEntity>) {}
            override suspend fun clearActive() {}
            override fun observeActivePeriod(): Flow<BudgetPeriodEntity?> = MutableStateFlow(period)
            override fun observeAll(): Flow<List<BudgetPeriodEntity>> = flowOf(listOf(period))
        }
        val targetDao = object : SavingTargetDao {
            override suspend fun upsert(target: SavingTargetEntity) {}
            override suspend fun upsertAll(items: List<SavingTargetEntity>) {}
            override fun observeByPeriod(periodId: String): Flow<SavingTargetEntity?> = MutableStateFlow(
                if (hasTarget) SavingTargetEntity("t1", periodId, 100_000) else null,
            )
            override fun observeAll(): Flow<List<SavingTargetEntity>> =
                flowOf(if (hasTarget) listOf(SavingTargetEntity("t1", period.id, 100_000)) else emptyList())
        }
        val allocDao = object : SavingAllocationDao {
            override suspend fun upsert(allocation: SavingAllocationEntity) {
                allocations.value = allocations.value + allocation
            }
            override suspend fun upsertAll(items: List<SavingAllocationEntity>) {}
            override fun observeByPeriod(periodId: String): Flow<List<SavingAllocationEntity>> = allocations
            override fun observeAll(): Flow<List<SavingAllocationEntity>> = allocations
        }
        val snapshotDao = object : DailyBudgetSnapshotDao {
            override suspend fun upsert(snapshot: DailyBudgetSnapshotEntity) {}
            override suspend fun upsertAll(items: List<DailyBudgetSnapshotEntity>) {}
            override fun observeByDate(periodId: String, date: LocalDate): Flow<DailyBudgetSnapshotEntity?> = MutableStateFlow(
                DailyBudgetSnapshotEntity("d1", periodId, date, 100_000, 50_000, 50_000),
            )
            override fun observeAll(): Flow<List<DailyBudgetSnapshotEntity>> = flowOf(
                listOf(DailyBudgetSnapshotEntity("d1", period.id, today, 100_000, 50_000, 50_000)),
            )
        }

        return Env(
            vm = SavingViewModel(
                budgetPeriodDao = budgetDao,
                savingTargetDao = targetDao,
                savingAllocationDao = allocDao,
                dailyBudgetSnapshotDao = snapshotDao,
                leftoverAllocationCalculator = LeftoverAllocationCalculator(),
            ),
            allocations = allocations,
        )
    }
}

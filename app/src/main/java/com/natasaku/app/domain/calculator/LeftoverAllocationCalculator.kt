package com.natasaku.app.domain.calculator

import com.natasaku.app.domain.model.LeftoverAllocationResult
import com.natasaku.app.domain.model.LeftoverAllocationType

class LeftoverAllocationCalculator {
    fun allocate(
        remainingToday: Long,
        type: LeftoverAllocationType,
    ): LeftoverAllocationResult {
        if (remainingToday <= 0L) return LeftoverAllocationResult()

        return when (type) {
            LeftoverAllocationType.NEXT_DAY -> LeftoverAllocationResult(toNextDay = remainingToday)
            LeftoverAllocationType.SAVING -> LeftoverAllocationResult(toSaving = remainingToday)
            LeftoverAllocationType.FREE_BALANCE -> LeftoverAllocationResult(toFreeBalance = remainingToday)
            LeftoverAllocationType.AUTO_SPLIT -> {
                val toSaving = remainingToday / 2
                val toNextDay = remainingToday - toSaving
                LeftoverAllocationResult(
                    toNextDay = toNextDay,
                    toSaving = toSaving,
                )
            }
        }
    }
}

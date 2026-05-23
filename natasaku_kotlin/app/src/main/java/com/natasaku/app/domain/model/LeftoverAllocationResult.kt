package com.natasaku.app.domain.model

data class LeftoverAllocationResult(
    val toNextDay: Long = 0L,
    val toSaving: Long = 0L,
    val toFreeBalance: Long = 0L,
)

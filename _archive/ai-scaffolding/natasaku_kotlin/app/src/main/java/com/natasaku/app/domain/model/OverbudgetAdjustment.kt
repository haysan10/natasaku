package com.natasaku.app.domain.model

data class OverbudgetAdjustment(
    val overbudgetAmount: Long,
    val remainingDays: Int,
    val adjustmentPerDay: Long,
)

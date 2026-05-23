package com.natasaku.app.presentation.component

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.natasaku.app.domain.model.BudgetStatus

@Composable
fun StatusChip(
    status: BudgetStatus,
    modifier: Modifier = Modifier,
) {
    NataStatusChip(
        status = status,
        modifier = modifier,
    )
}

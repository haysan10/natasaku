package com.natasaku.app.presentation.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

enum class BudgetStatus {
    SAFE,
    WARNING,
    OVER_BUDGET,
}

data class StatusColorTokens(
    val container: Color,
    val content: Color,
)

@Composable
fun statusColors(status: BudgetStatus): StatusColorTokens {
    return when (status) {
        BudgetStatus.SAFE -> StatusColorTokens(
            container = MaterialTheme.colorScheme.primaryContainer,
            content = MaterialTheme.colorScheme.onPrimaryContainer,
        )
        BudgetStatus.WARNING -> StatusColorTokens(
            container = MaterialTheme.colorScheme.tertiaryContainer,
            content = MaterialTheme.colorScheme.onTertiaryContainer,
        )
        BudgetStatus.OVER_BUDGET -> StatusColorTokens(
            container = MaterialTheme.colorScheme.errorContainer,
            content = MaterialTheme.colorScheme.onErrorContainer,
        )
    }
}

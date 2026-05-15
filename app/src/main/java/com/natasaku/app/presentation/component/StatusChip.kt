package com.natasaku.app.presentation.component

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.natasaku.app.presentation.theme.BudgetStatus
import com.natasaku.app.presentation.theme.NataSakuTheme
import com.natasaku.app.presentation.theme.statusColors

@Composable
fun StatusChip(
    status: BudgetStatus,
    modifier: Modifier = Modifier,
) {
    val colors = statusColors(status)
    Surface(
        modifier = modifier,
        shape = MaterialTheme.shapes.medium,
        color = colors.container,
        contentColor = colors.content,
    ) {
        Text(
            text = statusLabel(status),
            style = MaterialTheme.typography.labelLarge,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
        )
    }
}

private fun statusLabel(status: BudgetStatus): String {
    return when (status) {
        BudgetStatus.SAFE -> "Aman"
        BudgetStatus.WARNING -> "Waspada"
        BudgetStatus.OVER_BUDGET -> "Melewati batas"
    }
}

@Preview(showBackground = true)
@Composable
private fun StatusChipPreviewLight() {
    NataSakuTheme(darkTheme = false) {
        StatusChip(status = BudgetStatus.WARNING)
    }
}

@Preview(showBackground = true)
@Composable
private fun StatusChipPreviewDark() {
    NataSakuTheme(darkTheme = true) {
        StatusChip(status = BudgetStatus.OVER_BUDGET)
    }
}

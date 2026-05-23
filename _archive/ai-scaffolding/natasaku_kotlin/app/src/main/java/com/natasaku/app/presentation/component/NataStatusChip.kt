package com.natasaku.app.presentation.component

import androidx.compose.animation.Crossfade
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.natasaku.app.domain.model.BudgetStatus
import com.natasaku.app.presentation.theme.NataSakuTheme

@Composable
fun NataStatusChip(
    status: BudgetStatus,
    modifier: Modifier = Modifier,
) {
    val containerTarget = when (status) {
        BudgetStatus.SAFE -> MaterialTheme.colorScheme.primaryContainer
        BudgetStatus.WARNING -> MaterialTheme.colorScheme.tertiaryContainer
        BudgetStatus.OVER_BUDGET -> MaterialTheme.colorScheme.errorContainer
    }
    val contentTarget = when (status) {
        BudgetStatus.SAFE -> MaterialTheme.colorScheme.onPrimaryContainer
        BudgetStatus.WARNING -> MaterialTheme.colorScheme.onTertiaryContainer
        BudgetStatus.OVER_BUDGET -> MaterialTheme.colorScheme.onErrorContainer
    }
    val containerColor = animateColorAsState(containerTarget, tween(200), label = "statusContainer")
    val contentColor = animateColorAsState(contentTarget, tween(200), label = "statusContent")

    Surface(
        modifier = modifier,
        color = containerColor.value,
        contentColor = contentColor.value,
        shape = MaterialTheme.shapes.small,
        tonalElevation = 2.dp,
    ) {
        Crossfade(targetState = status, animationSpec = tween(200), label = "statusText") { target ->
            Text(
                text = when (target) {
                    BudgetStatus.SAFE -> "Aman"
                    BudgetStatus.WARNING -> "Waspada"
                    BudgetStatus.OVER_BUDGET -> "Melewati Batas"
                },
                style = MaterialTheme.typography.labelMedium,
                modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun NataStatusChipPreview() {
    NataSakuTheme {
        NataStatusChip(status = BudgetStatus.WARNING)
    }
}

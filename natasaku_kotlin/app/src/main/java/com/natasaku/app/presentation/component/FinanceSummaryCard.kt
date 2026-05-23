package com.natasaku.app.presentation.component

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.natasaku.app.presentation.theme.NataSakuTheme

@Composable
fun FinanceSummaryCard(
    title: String,
    amount: Long,
    description: String,
    modifier: Modifier = Modifier,
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(text = title, style = MaterialTheme.typography.titleMedium)
            MoneyText(amount = amount)
            Text(
                text = description,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun FinanceSummaryCardPreviewLight() {
    NataSakuTheme(darkTheme = false) {
        FinanceSummaryCard(
            title = "Jatah kamu hari ini",
            amount = 120000,
            description = "Aman. Pengeluaranmu masih terkendali.",
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun FinanceSummaryCardPreviewDark() {
    NataSakuTheme(darkTheme = true) {
        FinanceSummaryCard(
            title = "Jatah kamu hari ini",
            amount = 120000,
            description = "Aman. Pengeluaranmu masih terkendali.",
        )
    }
}

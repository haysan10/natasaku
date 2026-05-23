package com.natasaku.app.presentation.component

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import com.natasaku.app.core.money.RupiahFormatter

@Composable
fun MoneyText(
    amount: Long,
    modifier: Modifier = Modifier,
    style: TextStyle = MaterialTheme.typography.titleLarge,
) {
    val formatter = remember { RupiahFormatter() }
    Text(
        text = formatter.format(amount),
        modifier = modifier,
        style = style,
        color = MaterialTheme.colorScheme.onSurface,
    )
}

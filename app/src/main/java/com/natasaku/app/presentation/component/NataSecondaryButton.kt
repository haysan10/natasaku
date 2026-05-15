package com.natasaku.app.presentation.component

import androidx.compose.foundation.layout.heightIn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.natasaku.app.presentation.theme.NataSakuTheme

@Composable
fun NataSecondaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
) {
    OutlinedButton(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier.heightIn(min = 48.dp),
        shape = MaterialTheme.shapes.medium,
    ) {
        Text(text = text, style = MaterialTheme.typography.labelLarge)
    }
}

@Preview(showBackground = true)
@Composable
private fun NataSecondaryButtonPreviewLight() {
    NataSakuTheme(darkTheme = false) {
        NataSecondaryButton(text = "Batal", onClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun NataSecondaryButtonPreviewDark() {
    NataSakuTheme(darkTheme = true) {
        NataSecondaryButton(text = "Batal", onClick = {})
    }
}

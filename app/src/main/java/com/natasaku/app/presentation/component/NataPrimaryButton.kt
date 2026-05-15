package com.natasaku.app.presentation.component

import androidx.compose.foundation.layout.heightIn
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.natasaku.app.presentation.theme.NataSakuTheme

@Composable
fun NataPrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier.heightIn(min = 48.dp),
        shape = MaterialTheme.shapes.medium,
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.primary,
            contentColor = MaterialTheme.colorScheme.onPrimary,
        ),
    ) {
        Text(text = text, style = MaterialTheme.typography.labelLarge)
    }
}

@Preview(showBackground = true)
@Composable
private fun NataPrimaryButtonPreviewLight() {
    NataSakuTheme(darkTheme = false) {
        NataPrimaryButton(text = "Simpan", onClick = {})
    }
}

@Preview(showBackground = true)
@Composable
private fun NataPrimaryButtonPreviewDark() {
    NataSakuTheme(darkTheme = true) {
        NataPrimaryButton(text = "Simpan", onClick = {})
    }
}

package com.natasaku.app.presentation.component

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import com.natasaku.app.core.money.RupiahVisualTransformation
import com.natasaku.app.domain.validation.NominalInputValidator

@Composable
fun NominalInputField(
    value: TextFieldValue,
    onValueChange: (TextFieldValue) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    placeholder: String? = null,
    autofocusRequester: FocusRequester? = null,
    enabled: Boolean = true,
) {
    OutlinedTextField(
        value = value,
        onValueChange = { incoming ->
            val sanitized = NominalInputValidator.sanitizeRawInput(incoming.text).take(12)
            val clampedCursor = incoming.selection.start.coerceAtMost(sanitized.length)
            onValueChange(
                incoming.copy(
                    text = sanitized,
                    selection = androidx.compose.ui.text.TextRange(clampedCursor),
                ),
            )
        },
        modifier = modifier
            .fillMaxWidth()
            .then(if (autofocusRequester != null) Modifier.focusRequester(autofocusRequester) else Modifier),
        label = { Text(label) },
        placeholder = {
            if (placeholder != null) {
                Text(placeholder)
            }
        },
        trailingIcon = {
            if (value.text.isNotEmpty()) {
                IconButton(onClick = { onValueChange(TextFieldValue("")) }) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Hapus nominal",
                    )
                }
            }
        },
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
        visualTransformation = RupiahVisualTransformation(),
        singleLine = true,
        enabled = enabled,
    )
}

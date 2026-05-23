package com.natasaku.app.core.money

import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.input.OffsetMapping
import androidx.compose.ui.text.input.TransformedText
import androidx.compose.ui.text.input.VisualTransformation

class RupiahVisualTransformation(
    private val prefix: String = "Rp ",
) : VisualTransformation {
    override fun filter(text: AnnotatedString): TransformedText {
        val raw = text.text.filter(Char::isDigit)
        if (raw.isEmpty()) {
            return TransformedText(
                text = AnnotatedString(""),
                offsetMapping = OffsetMapping.Identity,
            )
        }

        val formattedNumber = buildString {
            raw.forEachIndexed { index, char ->
                append(char)
                val remaining = raw.length - index - 1
                if (remaining > 0 && remaining % 3 == 0) {
                    append('.')
                }
            }
        }
        val transformed = "$prefix$formattedNumber"

        val originalToTransformed = IntArray(raw.length + 1)
        var transformedIndex = prefix.length
        originalToTransformed[0] = transformedIndex
        raw.forEachIndexed { index, _ ->
            transformedIndex += 1
            originalToTransformed[index + 1] = transformedIndex
            val remaining = raw.length - index - 1
            if (remaining > 0 && remaining % 3 == 0) {
                transformedIndex += 1
            }
        }

        val transformedToOriginal = IntArray(transformed.length + 1)
        var originalIndex = 0
        for (i in transformed.indices) {
            val c = transformed[i]
            if (i < prefix.length || c == '.') {
                transformedToOriginal[i] = originalIndex
            } else {
                originalIndex = (originalIndex + 1).coerceAtMost(raw.length)
                transformedToOriginal[i] = originalIndex
            }
        }
        transformedToOriginal[transformed.length] = raw.length

        return TransformedText(
            text = AnnotatedString(transformed),
            offsetMapping = object : OffsetMapping {
                override fun originalToTransformed(offset: Int): Int {
                    val safe = offset.coerceIn(0, raw.length)
                    return originalToTransformed[safe]
                }

                override fun transformedToOriginal(offset: Int): Int {
                    val safe = offset.coerceIn(0, transformed.length)
                    return transformedToOriginal[safe].coerceIn(0, raw.length)
                }
            },
        )
    }
}

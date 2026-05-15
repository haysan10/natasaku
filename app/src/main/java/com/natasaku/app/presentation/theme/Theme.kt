package com.natasaku.app.presentation.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider

private val LightColorScheme = lightColorScheme(
    primary = NataPrimaryLight,
    onPrimary = NataSurfaceLight,
    primaryContainer = NataPrimarySoftLight,
    onPrimaryContainer = NataPrimaryDarkLight,
    secondary = NataSecondaryMintLight,
    background = NataBackgroundLight,
    onBackground = NataTextPrimaryLight,
    surface = NataSurfaceLight,
    onSurface = NataTextPrimaryLight,
    surfaceVariant = NataSurfaceVariantLight,
    onSurfaceVariant = NataTextSecondaryLight,
    outline = NataBorderLight,
    error = NataErrorLight,
    errorContainer = NataErrorSoftLight,
    onErrorContainer = NataErrorLight,
    tertiary = NataWarningLight,
    tertiaryContainer = NataWarningLight.copy(alpha = 0.2f),
    onTertiaryContainer = NataTextPrimaryLight,
)

private val DarkColorScheme = darkColorScheme(
    primary = NataPrimaryDark,
    onPrimary = NataBackgroundDark,
    primaryContainer = NataPrimaryContainerDark,
    onPrimaryContainer = NataTextPrimaryDark,
    background = NataBackgroundDark,
    onBackground = NataTextPrimaryDark,
    surface = NataSurfaceDark,
    onSurface = NataTextPrimaryDark,
    surfaceVariant = NataSurfaceVariantDark,
    onSurfaceVariant = NataTextSecondaryDark,
    outline = NataBorderDark,
    error = NataErrorDark,
    errorContainer = NataErrorDark.copy(alpha = 0.2f),
    onErrorContainer = NataTextPrimaryDark,
    tertiary = NataWarningDark,
    tertiaryContainer = NataWarningDark.copy(alpha = 0.2f),
    onTertiaryContainer = NataTextPrimaryDark,
)

@Composable
fun NataSakuTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    CompositionLocalProvider(LocalNataDimens provides NataDimens()) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = NataTypography,
            shapes = NataShapes,
            content = content,
        )
    }
}

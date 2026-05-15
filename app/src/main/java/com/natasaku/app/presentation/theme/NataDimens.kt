package com.natasaku.app.presentation.theme

import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

data class NataDimens(
    val screenHorizontalPadding: Dp = 20.dp,
    val sectionSpacing: Dp = 24.dp,
    val cardPadding: Dp = 16.dp,
    val cardRadius: Dp = 20.dp,
    val buttonRadius: Dp = 16.dp,
    val minTouchTarget: Dp = 48.dp,
)

val LocalNataDimens = staticCompositionLocalOf { NataDimens() }

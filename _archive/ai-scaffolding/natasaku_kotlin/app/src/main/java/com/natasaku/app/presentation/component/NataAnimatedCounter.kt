package com.natasaku.app.presentation.component

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateIntAsState
import androidx.compose.animation.core.tween
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.natasaku.app.core.money.RupiahFormatter
import com.natasaku.app.presentation.theme.NataSakuTheme

@Composable
fun NataAnimatedCounter(
    targetValue: Long,
    durationMs: Int,
    formatter: (Long) -> String,
    modifier: Modifier = Modifier,
) {
    var animationTarget by remember(targetValue) { mutableIntStateOf(0) }
    LaunchedEffect(targetValue) {
        animationTarget = targetValue.coerceIn(Int.MIN_VALUE.toLong(), Int.MAX_VALUE.toLong()).toInt()
    }
    val animated by animateIntAsState(
        targetValue = animationTarget,
        animationSpec = tween(durationMillis = durationMs, easing = FastOutSlowInEasing),
        label = "nataAnimatedCounter",
    )
    Text(
        text = formatter(animated.toLong()),
        modifier = modifier,
        style = MaterialTheme.typography.displaySmall,
    )
}

@Preview(showBackground = true)
@Composable
private fun NataAnimatedCounterPreview() {
    NataSakuTheme {
        NataAnimatedCounter(
            targetValue = 80000L,
            durationMs = 300,
            formatter = { RupiahFormatter().format(it) },
        )
    }
}

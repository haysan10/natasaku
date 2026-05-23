package com.natasaku.app.presentation.component

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.natasaku.app.presentation.theme.NataSakuTheme

@Composable
fun NataShimmerBox(
    width: Dp,
    height: Dp,
    shape: Shape,
    modifier: Modifier = Modifier,
) {
    val transition = rememberInfiniteTransition(label = "shimmerTransition")
    val shimmerTranslate = transition.animateFloat(
        initialValue = 0f,
        targetValue = 1000f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1100),
            repeatMode = RepeatMode.Restart,
        ),
        label = "shimmerTranslate",
    )

    val base = MaterialTheme.colorScheme.surfaceVariant
    val highlight = MaterialTheme.colorScheme.surface.copy(alpha = 0.8f)

    Box(
        modifier = modifier
            .width(width)
            .height(height)
            .clip(shape)
            .background(
                brush = Brush.linearGradient(
                    colors = listOf(base, highlight, base),
                    start = Offset(shimmerTranslate.value - 300f, 0f),
                    end = Offset(shimmerTranslate.value, 300f),
                ),
            ),
    )
}

@Preview(showBackground = true)
@Composable
private fun NataShimmerBoxPreview() {
    NataSakuTheme {
        NataShimmerBox(
            width = 220.dp,
            height = 72.dp,
            shape = RoundedCornerShape(16.dp),
        )
    }
}

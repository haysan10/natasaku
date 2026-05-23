package com.natasaku.app.presentation.component

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.fadeIn
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import com.natasaku.app.presentation.theme.NataSakuTheme

@Composable
fun NataSpotlightOverlay(
    targetRect: Rect?,
    tooltipText: String,
    stepNumber: Int,
    totalSteps: Int,
    onNext: () -> Unit,
    onSkip: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val scale by animateFloatAsState(
        targetValue = if (targetRect == null) 0.8f else 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow,
        ),
        label = "spotlightScale",
    )
    var rootSize = IntSize.Zero
    val density = LocalDensity.current

    Box(
        modifier = modifier
            .fillMaxSize()
            .onSizeChanged { rootSize = it }
            .graphicsLayer(alpha = 0.99f)
            .drawWithContent {
                drawRect(Color.Black.copy(alpha = 0.6f))
                val rect = targetRect
                if (rect != null) {
                    drawRoundRect(
                        color = Color.Transparent,
                        topLeft = rect.topLeft,
                        size = rect.size,
                        cornerRadius = CornerRadius(24f, 24f),
                        blendMode = BlendMode.Clear,
                    )
                }
            }
            .clickable(onClick = onNext),
    ) {
        Text(
            text = "Lewati",
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(16.dp)
                .clickable(onClick = onSkip),
            style = MaterialTheme.typography.labelLarge,
            color = Color.White,
        )

        val tooltipY = with(density) {
            val rect = targetRect
            if (rect == null) 140.dp
            else {
                val candidate = rect.bottom + 16.dp.toPx()
                val maxAllowed = rootSize.height - 180.dp.toPx()
                ((candidate.coerceAtMost(maxAllowed)) / density).dp
            }
        }

        AnimatedVisibility(
            visible = true,
            enter = fadeIn() + slideInVertically(initialOffsetY = { it / 5 }),
            modifier = Modifier
                .align(Alignment.TopStart)
                .offset(y = tooltipY)
                .padding(horizontal = 16.dp),
        ) {
            Surface(
                shape = MaterialTheme.shapes.medium,
                tonalElevation = 4.dp,
                modifier = Modifier.graphicsLayer {
                    scaleX = scale
                    scaleY = scale
                },
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Text(
                        text = "Langkah $stepNumber/$totalSteps",
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.primary,
                    )
                    Text(
                        text = tooltipText,
                        style = MaterialTheme.typography.bodyMedium,
                    )
                    NataPrimaryButton(
                        text = "Mengerti →",
                        onClick = onNext,
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun NataSpotlightOverlayPreview() {
    NataSakuTheme {
        Box(modifier = Modifier.fillMaxSize().background(Color(0xFFEFEFEF))) {
            NataSpotlightOverlay(
                targetRect = Rect(40f, 180f, 360f, 340f),
                tooltipText = "Ini jatah harimu. Angka ini dihitung otomatis dari penghasilanmu dikurangi kebutuhan tetap dan tabungan.",
                stepNumber = 1,
                totalSteps = 5,
                onNext = {},
                onSkip = {},
            )
        }
    }
}

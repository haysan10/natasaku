package com.natasaku.app.presentation.navigation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.natasaku.app.presentation.featuretour.FeatureTourManager
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

enum class FeatureTourAnchor {
    HERO_CARD,
    FAB_ADD_EXPENSE,
    STATUS_CHIP,
    TAB_REPORTS,
    TAB_SAVING,
}

data class FeatureTourStep(
    val anchor: FeatureTourAnchor,
    val message: String,
    val primaryButtonText: String,
)

data class MainTabsUiState(
    val isTourVisible: Boolean = false,
    val currentStepIndex: Int = 0,
    val steps: List<FeatureTourStep> = emptyList(),
)

@HiltViewModel
class MainTabsViewModel @Inject constructor(
    private val featureTourManager: FeatureTourManager,
) : ViewModel() {
    private val _uiState = MutableStateFlow(MainTabsUiState())
    val uiState = _uiState.asStateFlow()

    private val tourSteps = listOf(
        FeatureTourStep(
            anchor = FeatureTourAnchor.HERO_CARD,
            message = "Ini jatah harimu. Angka ini dihitung otomatis dari penghasilanmu dikurangi kebutuhan tetap dan tabungan.",
            primaryButtonText = "Mengerti →",
        ),
        FeatureTourStep(
            anchor = FeatureTourAnchor.FAB_ADD_EXPENSE,
            message = "Tap di sini setiap kali kamu belanja. Makin cepat catat, makin akurat jatahmu.",
            primaryButtonText = "Oke →",
        ),
        FeatureTourStep(
            anchor = FeatureTourAnchor.STATUS_CHIP,
            message = "Warna dan teks ini menunjukkan kondisi keuanganmu hari ini. Hijau = aman, kuning = hati-hati, merah muda = sudah lewat batas.",
            primaryButtonText = "Paham →",
        ),
        FeatureTourStep(
            anchor = FeatureTourAnchor.TAB_REPORTS,
            message = "Di sini kamu bisa lihat laporan harian, mingguan, bulanan, sampai tahunan. Semua tersimpan rapi.",
            primaryButtonText = "Lihat →",
        ),
        FeatureTourStep(
            anchor = FeatureTourAnchor.TAB_SAVING,
            message = "Tabunganmu dipantau di sini. Kamu bisa atur jadwal otomatis agar tidak lupa menyisihkan.",
            primaryButtonText = "Selesai 🎉",
        ),
    )

    fun loadTourState() = viewModelScope.launch {
        val shouldStart = featureTourManager.shouldStart()
        _uiState.update {
            it.copy(
                isTourVisible = shouldStart,
                currentStepIndex = 0,
                steps = tourSteps,
            )
        }
    }

    fun nextStep() = viewModelScope.launch {
        val current = _uiState.value
        val nextIndex = current.currentStepIndex + 1
        if (nextIndex >= current.steps.size) {
            featureTourManager.markCompleted()
            _uiState.update { it.copy(isTourVisible = false, currentStepIndex = 0) }
        } else {
            _uiState.update { it.copy(currentStepIndex = nextIndex) }
        }
    }

    fun skipTour() = viewModelScope.launch {
        featureTourManager.markCompleted()
        _uiState.update { it.copy(isTourVisible = false, currentStepIndex = 0) }
    }
}

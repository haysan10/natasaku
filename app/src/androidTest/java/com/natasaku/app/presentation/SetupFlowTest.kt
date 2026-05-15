package com.natasaku.app.presentation

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import com.natasaku.app.MainActivity
import org.junit.Rule
import org.junit.Test

class SetupFlowTest {
    @get:Rule
    val rule = createAndroidComposeRule<MainActivity>()

    @Test
    fun happyPath_setupFlow_navigatesToHome() {
        rule.onNodeWithText("Masuk").assertIsDisplayed().performClick()
        rule.onNodeWithText("Mulai Atur Budget").assertIsDisplayed().performClick()
        rule.onNodeWithText("Lanjut").assertIsDisplayed().performClick()

        rule.onNodeWithText("Nama periode").performTextInput("Mei 2026")
        rule.onNodeWithText("Tanggal mulai (YYYY-MM-DD)").performTextInput("2026-05-01")
        rule.onNodeWithText("Tanggal akhir (YYYY-MM-DD)").performTextInput("2026-05-31")
        rule.onNodeWithText("Lanjut").performClick()

        rule.onNodeWithText("Nama penghasilan").performTextInput("Gaji")
        rule.onNodeWithText("Nominal").performTextInput("3000000")
        rule.onNodeWithText("Tambah Penghasilan").performClick()
        rule.onNodeWithText("Lanjut").performClick()

        rule.onNodeWithText("Nama pengeluaran").performTextInput("Kos")
        rule.onNodeWithText("Nominal").performTextInput("1000000")
        rule.onNodeWithText("Tambah Pengeluaran").performClick()
        rule.onNodeWithText("Lanjut").performClick()

        rule.onNodeWithText("Target tabungan (opsional)").performTextInput("500000")
        rule.onNodeWithText("Lanjut").performClick()

        rule.onNodeWithText("Selesai").performClick()
        rule.onNodeWithText("Home Placeholder").assertIsDisplayed()
    }
}

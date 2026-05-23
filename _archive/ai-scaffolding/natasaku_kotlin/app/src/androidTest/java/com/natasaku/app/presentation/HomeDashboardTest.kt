package com.natasaku.app.presentation

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import com.natasaku.app.MainActivity
import org.junit.Rule
import org.junit.Test

class HomeDashboardTest {
    @get:Rule
    val rule = createAndroidComposeRule<MainActivity>()

    @Test
    fun addExpenseSheet_showsValidationError_whenAmountInvalid() {
        rule.onNodeWithText("Masuk").performClick()
        rule.onNodeWithText("Mulai Atur Budget").performClick()
        rule.onNodeWithText("Lanjut").performClick()

        rule.onNodeWithText("Nama periode").performTextInput("Mei 2026")
        rule.onNodeWithText("Tanggal mulai (YYYY-MM-DD)").performTextInput("2026-05-01")
        rule.onNodeWithText("Tanggal akhir (YYYY-MM-DD)").performTextInput("2026-05-31")
        rule.onNodeWithText("Lanjut").performClick()

        rule.onNodeWithText("Nama penghasilan").performTextInput("Gaji")
        rule.onNodeWithText("Nominal").performTextInput("3000000")
        rule.onNodeWithText("Tambah Penghasilan").performClick()
        rule.onNodeWithText("Lanjut").performClick()

        rule.onNodeWithText("Lanjut").performClick()
        rule.onNodeWithText("Lewati").performClick()
        rule.onNodeWithText("Selesai").performClick()

        rule.onNodeWithText("+").performClick()
        rule.onNodeWithText("Kategori").performTextInput("Makan")
        rule.onNodeWithText("Simpan Pengeluaran").performClick()

        rule.onNodeWithText("Nominal belum valid. Masukkan nominal lebih dari Rp0, ya.").assertIsDisplayed()
    }
}

package com.natasaku.app.core.money

import java.text.NumberFormat
import java.util.Locale

class RupiahFormatter : MoneyFormatter {
    override fun format(amount: Long): String {
        val formatter = NumberFormat.getCurrencyInstance(Locale("in", "ID"))
        formatter.maximumFractionDigits = 0
        return formatter.format(amount).replace("Rp", "Rp ")
    }
}

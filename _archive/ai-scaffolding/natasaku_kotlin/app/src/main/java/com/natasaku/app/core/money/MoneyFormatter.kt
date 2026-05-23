package com.natasaku.app.core.money

interface MoneyFormatter {
    fun format(amount: Long): String
}

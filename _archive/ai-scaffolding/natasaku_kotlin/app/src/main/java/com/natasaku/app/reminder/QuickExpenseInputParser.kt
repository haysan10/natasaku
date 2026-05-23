package com.natasaku.app.reminder

import java.time.LocalDate
import java.util.Locale
import java.util.UUID
import kotlin.math.roundToLong

object QuickExpenseInputParser {
    private val amountRegex = Regex("""([0-9][0-9.,\s]*)(?:\s*(rb|k|jt|juta|m))?""", RegexOption.IGNORE_CASE)

    fun parseToPendingTransaction(rawInput: String, nowDate: LocalDate = LocalDate.now()): PendingQuickTransaction? {
        val parsed = parse(rawInput) ?: return null
        return PendingQuickTransaction(
            id = "TRX_${UUID.randomUUID()}",
            dateIso = "${nowDate}T12:00:00Z",
            type = parsed.type,
            category = parsed.category,
            amount = parsed.amount,
            note = parsed.note,
            source = parsed.source,
            currencyCode = parsed.currencyCode,
        )
    }

    private fun parse(input: String): ParsedQuickInput? {
        val text = input.trim()
        if (text.isBlank()) return null

        val lowered = text.lowercase(Locale.ROOT)
        val type = detectType(lowered)
        val currency = detectCurrency(lowered)

        val amountMatch = amountRegex.find(lowered) ?: return null
        val numberRaw = amountMatch.groupValues[1]
        val suffix = amountMatch.groupValues.getOrNull(2)?.trim()?.lowercase(Locale.ROOT).orEmpty()

        val amount = parseNumeric(numberRaw, suffix) ?: return null

        val source = detectSource(lowered)
        val category = detectCategory(lowered, type)

        val note = text
            .replace(amountMatch.value, " ")
            .replace("rp", " ", ignoreCase = true)
            .replace("idr", " ", ignoreCase = true)
            .replace("usd", " ", ignoreCase = true)
            .replace("eur", " ", ignoreCase = true)
            .replace("sgd", " ", ignoreCase = true)
            .replace("jpy", " ", ignoreCase = true)
            .replace("gbp", " ", ignoreCase = true)
            .replace("aud", " ", ignoreCase = true)
            .replace("income", " ", ignoreCase = true)
            .replace("pemasukan", " ", ignoreCase = true)
            .replace("pengeluaran", " ", ignoreCase = true)
            .replace("expense", " ", ignoreCase = true)
            .replace(Regex("\\s+"), " ")
            .trim()
            .ifBlank { if (type == "Pemasukan") "Pemasukan cepat" else "Pengeluaran cepat" }

        return ParsedQuickInput(
            type = type,
            amount = amount,
            currencyCode = currency,
            note = note,
            source = source,
            category = category,
        )
    }

    private fun detectType(lowered: String): String {
        val incomeKeywords = listOf("pemasukan", "income", "gaji", "bonus", "freelance", "fee", "komisi", "komisyen", "refund", "cashback", "masuk")
        return if (incomeKeywords.any { lowered.contains(it) }) "Pemasukan" else "Pengeluaran"
    }

    private fun detectCurrency(lowered: String): String {
        return when {
            lowered.contains("usd") || lowered.contains("$") -> "USD"
            lowered.contains("eur") || lowered.contains("€") -> "EUR"
            lowered.contains("sgd") -> "SGD"
            lowered.contains("jpy") || lowered.contains("¥") -> "JPY"
            lowered.contains("gbp") || lowered.contains("£") -> "GBP"
            lowered.contains("aud") -> "AUD"
            else -> "IDR"
        }
    }

    private fun detectSource(lowered: String): String {
        return when {
            lowered.contains("gopay") -> "GoPay"
            lowered.contains("ovo") -> "OVO"
            lowered.contains("dana") -> "DANA"
            lowered.contains("bca") -> "BCA"
            lowered.contains("bri") -> "BRI"
            lowered.contains("mandiri") -> "Mandiri"
            lowered.contains("cash") || lowered.contains("tunai") -> "Tunai"
            else -> ""
        }
    }

    private fun detectCategory(lowered: String, type: String): String {
        if (type == "Pemasukan") {
            return when {
                lowered.contains("gaji") -> "Gaji"
                lowered.contains("freelance") || lowered.contains("fee") -> "Freelance"
                lowered.contains("bonus") -> "Bonus"
                lowered.contains("refund") || lowered.contains("cashback") -> "Refund"
                else -> "Pemasukan Lain"
            }
        }

        return when {
            lowered.contains("makan") || lowered.contains("kopi") || lowered.contains("minum") -> "Makan & Minum"
            lowered.contains("bensin") || lowered.contains("transport") || lowered.contains("ojek") -> "Transportasi"
            lowered.contains("tagihan") || lowered.contains("listrik") || lowered.contains("air") || lowered.contains("internet") -> "Tagihan"
            lowered.contains("belanja") || lowered.contains("market") || lowered.contains("shopee") -> "Belanja"
            lowered.contains("hiburan") || lowered.contains("nonton") -> "Hiburan"
            else -> "Lainnya"
        }
    }

    private fun parseNumeric(rawNumber: String, suffix: String): Long? {
        val cleaned = rawNumber.replace(" ", "")
        if (cleaned.isBlank()) return null

        val normalized = when {
            cleaned.contains(',') && cleaned.contains('.') -> cleaned.replace(".", "").replace(',', '.')
            cleaned.count { it == ',' } > 1 -> cleaned.replace(",", "")
            cleaned.count { it == '.' } > 1 -> cleaned.replace(".", "")
            cleaned.contains(',') && cleaned.length - cleaned.lastIndexOf(',') <= 3 -> cleaned.replace(',', '.')
            else -> cleaned.replace(",", "")
        }

        val base = normalized.toDoubleOrNull() ?: return null

        val multiplier = when (suffix) {
            "rb", "k" -> 1_000.0
            "jt", "juta", "m" -> 1_000_000.0
            else -> 1.0
        }

        return (base * multiplier).roundToLong().takeIf { it > 0 }
    }
}

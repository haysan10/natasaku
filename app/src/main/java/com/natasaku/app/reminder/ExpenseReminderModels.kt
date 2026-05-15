package com.natasaku.app.reminder

import org.json.JSONArray
import org.json.JSONObject

data class PendingQuickTransaction(
    val id: String,
    val dateIso: String,
    val type: String,
    val category: String,
    val amount: Long,
    val note: String,
    val source: String,
    val currencyCode: String,
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("dateIso", dateIso)
        .put("type", type)
        .put("category", category)
        .put("amount", amount)
        .put("note", note)
        .put("source", source)
        .put("currencyCode", currencyCode)

    companion object {
        fun fromJson(obj: JSONObject): PendingQuickTransaction = PendingQuickTransaction(
            id = obj.optString("id"),
            dateIso = obj.optString("dateIso"),
            type = obj.optString("type", "Pengeluaran"),
            category = obj.optString("category", "Lainnya"),
            amount = obj.optLong("amount", 0L),
            note = obj.optString("note", ""),
            source = obj.optString("source", ""),
            currencyCode = obj.optString("currencyCode", "IDR"),
        )
    }
}

data class ParsedQuickInput(
    val type: String,
    val amount: Long,
    val currencyCode: String,
    val note: String,
    val source: String,
    val category: String,
)

internal fun JSONArray.toMutableList(): MutableList<JSONObject> {
    val list = mutableListOf<JSONObject>()
    for (i in 0 until length()) {
        val obj = optJSONObject(i) ?: continue
        list += obj
    }
    return list
}

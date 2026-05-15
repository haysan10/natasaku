package com.natasaku.app.data.export

import android.content.Context
import android.net.Uri
import androidx.core.content.FileProvider
import androidx.room.withTransaction
import com.natasaku.app.data.datastore.UserPreferenceDataStore
import com.natasaku.app.data.local.dao.BackupRestoreDao
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.database.NataSakuDatabase
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import com.natasaku.app.data.local.entity.DailyBudgetSnapshotEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.data.local.entity.FixedExpenseEntity
import com.natasaku.app.data.local.entity.IncomeSourceEntity
import com.natasaku.app.data.local.entity.SavingAllocationEntity
import com.natasaku.app.data.local.entity.SavingTargetEntity
import com.natasaku.app.domain.model.DefaultLeftoverAllocation
import com.natasaku.app.domain.model.ExportedFileUiModel
import com.natasaku.app.domain.model.ExpenseSource
import com.natasaku.app.domain.model.FixedExpenseStatus
import com.natasaku.app.domain.model.ThemeMode
import com.natasaku.app.domain.model.UserPreference
import java.io.File
import java.time.Instant
import java.time.LocalDate
import kotlinx.coroutines.flow.first
import org.json.JSONArray
import org.json.JSONObject

private const val AUTHORITY_SUFFIX = ".fileprovider"

class BackupRestoreService(
    private val context: Context,
    private val db: NataSakuDatabase,
    private val budgetPeriodDao: BudgetPeriodDao,
    private val incomeSourceDao: IncomeSourceDao,
    private val fixedExpenseDao: FixedExpenseDao,
    private val transactionDao: ExpenseTransactionDao,
    private val savingTargetDao: SavingTargetDao,
    private val savingAllocationDao: SavingAllocationDao,
    private val dailyBudgetSnapshotDao: DailyBudgetSnapshotDao,
    private val backupRestoreDao: BackupRestoreDao,
    private val preferenceDataStore: UserPreferenceDataStore,
) {
    suspend fun backup(): ExportedFileUiModel {
        val prefs = preferenceDataStore.preferences.first()
        val root = JSONObject().apply {
            put("app", "NataSaku")
            put("schemaVersion", 1)
            put("exportedAt", Instant.now().toString())
            put("data", JSONObject().apply {
                put("budgetPeriods", JSONArray().apply { budgetPeriodDao.observeAll().first().forEach { put(it.toJson()) } })
                put("incomeSources", JSONArray().apply { incomeSourceDao.observeAll().first().forEach { put(JSONObject().put("id", it.id).put("periodId", it.periodId).put("name", it.name).put("amount", it.amount)) } })
                put("fixedExpenses", JSONArray().apply { fixedExpenseDao.observeAll().first().forEach { put(it.toJson()) } })
                put("expenseTransactions", JSONArray().apply { transactionDao.observeAll().first().forEach { put(it.toJson()) } })
                put("savingTargets", JSONArray().apply { savingTargetDao.observeAll().first().forEach { put(JSONObject().put("id", it.id).put("periodId", it.periodId).put("targetAmount", it.targetAmount)) } })
                put("savingAllocations", JSONArray().apply { savingAllocationDao.observeAll().first().forEach { put(JSONObject().put("id", it.id).put("periodId", it.periodId).put("amount", it.amount).put("date", it.date.toString()).put("source", it.source)) } })
                put("dailyBudgetSnapshots", JSONArray().apply { dailyBudgetSnapshotDao.observeAll().first().forEach { put(JSONObject().put("id", it.id).put("periodId", it.periodId).put("date", it.date.toString()).put("finalDailyAllowance", it.finalDailyAllowance).put("spentToday", it.spentToday).put("remainingToday", it.remainingToday)) } })
                put("preferences", prefs.toJson())
            })
        }

        val file = File(context.cacheDir, "NataSaku_Backup_${LocalDate.now().toString().replace('-', '_')}.json")
        file.writeText(root.toString(2), Charsets.UTF_8)
        val uri = runCatching { FileProvider.getUriForFile(context, context.packageName + AUTHORITY_SUFFIX, file) }.getOrElse { Uri.fromFile(file) }
        return ExportedFileUiModel(file.name, uri, "application/json", file.length(), Instant.now())
    }

    suspend fun restoreFromJson(jsonText: String): Result<Unit> = runCatching {
        val root = JSONObject(jsonText)
        validate(root)
        val data = root.getJSONObject("data")
        db.withTransaction {
            backupRestoreDao.clearDailyBudgetSnapshots(); backupRestoreDao.clearSavingAllocations(); backupRestoreDao.clearSavingTargets()
            backupRestoreDao.clearExpenseTransactions(); backupRestoreDao.clearFixedExpenses(); backupRestoreDao.clearIncomeSources(); backupRestoreDao.clearBudgetPeriods()

            budgetPeriodDao.upsertAll(data.getJSONArray("budgetPeriods").toBudgetPeriods())
            incomeSourceDao.upsertAll(data.getJSONArray("incomeSources").toIncome())
            fixedExpenseDao.upsertAll(data.getJSONArray("fixedExpenses").toFixed())
            transactionDao.upsertAll(data.getJSONArray("expenseTransactions").toTransactions())
            savingTargetDao.upsertAll(data.getJSONArray("savingTargets").toTargets())
            savingAllocationDao.upsertAll(data.getJSONArray("savingAllocations").toAllocations())
            dailyBudgetSnapshotDao.upsertAll(data.getJSONArray("dailyBudgetSnapshots").toSnapshots())
            preferenceDataStore.update(data.getJSONObject("preferences").toPreference())
        }
    }

    private fun validate(root: JSONObject) {
        require(root.optString("app") == "NataSaku") { "File backup tidak bisa dibaca. Pastikan file berasal dari NataSaku." }
        require(root.optInt("schemaVersion", -1) == 1) { "Versi file backup belum didukung oleh aplikasi ini." }
        val data = root.optJSONObject("data") ?: error("Data backup tidak tersedia.")
        val required = listOf("budgetPeriods", "incomeSources", "fixedExpenses", "expenseTransactions", "savingTargets", "savingAllocations", "dailyBudgetSnapshots", "preferences")
        require(required.all { data.has(it) }) { "Struktur backup tidak lengkap." }
    }
}

private fun BudgetPeriodEntity.toJson() = JSONObject().put("id", id).put("name", name).put("startDate", startDate.toString()).put("endDate", endDate.toString()).put("isActive", isActive).put("createdAt", createdAt.toEpochMilli()).put("updatedAt", updatedAt.toEpochMilli())
private fun FixedExpenseEntity.toJson() = JSONObject().put("id", id).put("periodId", periodId).put("name", name).put("amount", amount).put("dueDay", dueDay).put("status", status.name).put("snoozedUntilTs", snoozedUntilTs?.toEpochMilli()).put("paidAt", paidAt?.toEpochMilli()).put("createdAt", createdAt.toEpochMilli())
private fun ExpenseTransactionEntity.toJson() = JSONObject().put("id", id).put("periodId", periodId).put("amount", amount).put("category", category).put("date", date.toString()).put("note", note).put("createdAt", createdAt.toEpochMilli()).put("updatedAt", updatedAt.toEpochMilli()).put("deletedAt", deletedAt?.toEpochMilli()).put("source", source.name).put("fixedExpenseId", fixedExpenseId)
private fun UserPreference.toJson() = JSONObject().put("currencyCode", currencyCode).put("themeMode", themeMode.name).put("defaultLeftoverAllocation", defaultLeftoverAllocation.name).put("dailyReminderEnabled", dailyReminderEnabled).put("dailyReminderTime", dailyReminderTime).put("onboardingCompleted", onboardingCompleted).put("activePeriodId", activePeriodId)

private fun JSONArray.toBudgetPeriods() = (0 until length()).map { i -> getJSONObject(i) }.map {
    BudgetPeriodEntity(it.getString("id"), it.getString("name"), LocalDate.parse(it.getString("startDate")), LocalDate.parse(it.getString("endDate")), it.getBoolean("isActive"), Instant.ofEpochMilli(it.getLong("createdAt")), Instant.ofEpochMilli(it.getLong("updatedAt")))
}
private fun JSONArray.toIncome() = (0 until length()).map { i -> getJSONObject(i) }.map { IncomeSourceEntity(it.getString("id"), it.getString("periodId"), it.getString("name"), it.getLong("amount")) }
private fun JSONArray.toFixed() = (0 until length()).map { i -> getJSONObject(i) }.map {
    FixedExpenseEntity(
        id = it.getString("id"),
        periodId = it.getString("periodId"),
        name = it.getString("name"),
        amount = it.getLong("amount"),
        dueDay = it.optInt("dueDay", 1),
        status = runCatching { FixedExpenseStatus.valueOf(it.optString("status", "COMMITTED")) }.getOrDefault(FixedExpenseStatus.COMMITTED),
        snoozedUntilTs = if (it.isNull("snoozedUntilTs")) null else Instant.ofEpochMilli(it.getLong("snoozedUntilTs")),
        paidAt = if (it.isNull("paidAt")) null else Instant.ofEpochMilli(it.getLong("paidAt")),
        createdAt = if (it.has("createdAt")) Instant.ofEpochMilli(it.getLong("createdAt")) else Instant.now(),
    )
}
private fun JSONArray.toTransactions() = (0 until length()).map { i -> getJSONObject(i) }.map {
    ExpenseTransactionEntity(it.getString("id"), it.getString("periodId"), it.getLong("amount"), it.getString("category"), LocalDate.parse(it.getString("date")), it.optString("note").ifBlank { null }, Instant.ofEpochMilli(it.getLong("createdAt")), Instant.ofEpochMilli(it.getLong("updatedAt")), if (it.isNull("deletedAt")) null else Instant.ofEpochMilli(it.getLong("deletedAt")))
        .copy(
            source = runCatching { ExpenseSource.valueOf(it.optString("source", "MANUAL")) }.getOrDefault(ExpenseSource.MANUAL),
            fixedExpenseId = if (it.isNull("fixedExpenseId")) null else it.optString("fixedExpenseId"),
        )
}
private fun JSONArray.toTargets() = (0 until length()).map { i -> getJSONObject(i) }.map { SavingTargetEntity(it.getString("id"), it.getString("periodId"), it.getLong("targetAmount")) }
private fun JSONArray.toAllocations() = (0 until length()).map { i -> getJSONObject(i) }.map { SavingAllocationEntity(it.getString("id"), it.getString("periodId"), it.getLong("amount"), LocalDate.parse(it.getString("date")), it.getString("source")) }
private fun JSONArray.toSnapshots() = (0 until length()).map { i -> getJSONObject(i) }.map { DailyBudgetSnapshotEntity(it.getString("id"), it.getString("periodId"), LocalDate.parse(it.getString("date")), it.getLong("finalDailyAllowance"), it.getLong("spentToday"), it.getLong("remainingToday")) }

private fun JSONObject.toPreference() = UserPreference(
    currencyCode = optString("currencyCode", "IDR"),
    themeMode = runCatching { ThemeMode.valueOf(optString("themeMode", "SYSTEM")) }.getOrDefault(ThemeMode.SYSTEM),
    defaultLeftoverAllocation = runCatching { DefaultLeftoverAllocation.valueOf(optString("defaultLeftoverAllocation", "ASK_EVERY_TIME")) }.getOrDefault(DefaultLeftoverAllocation.ASK_EVERY_TIME),
    dailyReminderEnabled = optBoolean("dailyReminderEnabled", false),
    dailyReminderTime = optString("dailyReminderTime", "20:00"),
    onboardingCompleted = optBoolean("onboardingCompleted", false),
    activePeriodId = if (isNull("activePeriodId")) null else optString("activePeriodId"),
)

package com.natasaku.app.data.export

import android.content.Context
import android.net.Uri
import androidx.core.content.FileProvider
import androidx.room.withTransaction
import com.natasaku.app.BuildConfig
import com.natasaku.app.data.datastore.UserPreferenceDataStore
import com.natasaku.app.data.local.dao.BackupRestoreDao
import com.natasaku.app.data.local.dao.BudgetPeriodDao
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao
import com.natasaku.app.data.local.dao.ExpenseTransactionDao
import com.natasaku.app.data.local.dao.FixedExpenseDao
import com.natasaku.app.data.local.dao.IncomeSourceDao
import com.natasaku.app.data.local.dao.SavingAllocationDao
import com.natasaku.app.data.local.dao.ScheduledPaymentDao
import com.natasaku.app.data.local.dao.ScheduledPaymentExecutionDao
import com.natasaku.app.data.local.dao.ScheduledSavingDao
import com.natasaku.app.data.local.dao.ScheduledSavingExecutionDao
import com.natasaku.app.data.local.dao.SavingTargetDao
import com.natasaku.app.data.local.database.NataSakuDatabase
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import com.natasaku.app.data.local.entity.DailyBudgetSnapshotEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.data.local.entity.FixedExpenseEntity
import com.natasaku.app.data.local.entity.IncomeSourceEntity
import com.natasaku.app.data.local.entity.SavingAllocationEntity
import com.natasaku.app.data.local.entity.SavingTargetEntity
import com.natasaku.app.data.local.entity.ScheduledPaymentEntity
import com.natasaku.app.data.local.entity.ScheduledPaymentExecutionEntity
import com.natasaku.app.data.local.entity.ScheduledSavingEntity
import com.natasaku.app.data.local.entity.ScheduledSavingExecutionEntity
import com.natasaku.app.domain.model.DefaultLeftoverAllocation
import com.natasaku.app.domain.model.ExportedFileUiModel
import com.natasaku.app.domain.model.ExpenseSource
import com.natasaku.app.domain.model.FixedExpenseStatus
import com.natasaku.app.domain.model.ExecutionStatus
import com.natasaku.app.domain.model.PaymentFrequency
import com.natasaku.app.domain.model.SavingFrequency
import com.natasaku.app.domain.model.ThemeMode
import com.natasaku.app.domain.model.UserPreference
import com.natasaku.app.domain.validation.BackupRestoreValidator
import java.io.File
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
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
    private val scheduledPaymentDao: ScheduledPaymentDao,
    private val scheduledPaymentExecutionDao: ScheduledPaymentExecutionDao,
    private val scheduledSavingDao: ScheduledSavingDao,
    private val scheduledSavingExecutionDao: ScheduledSavingExecutionDao,
    private val backupRestoreDao: BackupRestoreDao,
    private val preferenceDataStore: UserPreferenceDataStore,
) {
    enum class RestoreMode { REPLACE_ALL, MERGE_APPEND }

    fun getDatabaseSizeBytes(): Long {
        return context.getDatabasePath("natasaku.db")?.length() ?: 0L
    }

    suspend fun backup(): ExportedFileUiModel {
        val prefs = preferenceDataStore.preferences.first()
        val root = JSONObject().apply {
            put("app", "NataSaku")
            put("schemaVersion", BackupRestoreValidator.CURRENT_SCHEMA_VERSION)
            put("exportedAt", Instant.now().atZone(ZoneId.systemDefault()).toOffsetDateTime().toString())
            put(
                "deviceInfo",
                JSONObject().apply {
                    put("appVersion", BuildConfig.VERSION_NAME)
                    put("buildNumber", BuildConfig.VERSION_CODE)
                },
            )
            put("data", JSONObject().apply {
                put("budgetPeriods", JSONArray().apply { budgetPeriodDao.observeAll().first().forEach { put(it.toJson()) } })
                put("incomeSources", JSONArray().apply { incomeSourceDao.observeAll().first().forEach { put(JSONObject().put("id", it.id).put("periodId", it.periodId).put("name", it.name).put("amount", it.amount)) } })
                put("fixedExpenses", JSONArray().apply { fixedExpenseDao.observeAll().first().forEach { put(it.toJson()) } })
                put("expenseTransactions", JSONArray().apply { transactionDao.observeAll().first().forEach { put(it.toJson()) } })
                put("savingTargets", JSONArray().apply { savingTargetDao.observeAll().first().forEach { put(JSONObject().put("id", it.id).put("periodId", it.periodId).put("targetAmount", it.targetAmount)) } })
                put("savingAllocations", JSONArray().apply { savingAllocationDao.observeAll().first().forEach { put(JSONObject().put("id", it.id).put("periodId", it.periodId).put("amount", it.amount).put("date", it.date.toString()).put("source", it.source)) } })
                put("dailyBudgetSnapshots", JSONArray().apply { dailyBudgetSnapshotDao.observeAll().first().forEach { put(JSONObject().put("id", it.id).put("periodId", it.periodId).put("date", it.date.toString()).put("finalDailyAllowance", it.finalDailyAllowance).put("spentToday", it.spentToday).put("remainingToday", it.remainingToday)) } })
                put("scheduledPayments", JSONArray().apply { scheduledPaymentDao.observeAll().first().forEach { put(it.toJson()) } })
                put("scheduledPaymentExecutions", JSONArray().apply {
                    scheduledPaymentDao.observeAll().first().forEach { item ->
                        scheduledPaymentExecutionDao.observeByScheduledPayment(item.id).first().forEach { put(it.toJson()) }
                    }
                })
                put("scheduledSavings", JSONArray().apply { scheduledSavingDao.observeAll().first().forEach { put(it.toJson()) } })
                put("scheduledSavingExecutions", JSONArray().apply {
                    scheduledSavingDao.observeAll().first().forEach { item ->
                        scheduledSavingExecutionDao.observeByScheduledSaving(item.id).first().forEach { put(it.toJson()) }
                    }
                })
                put("preferences", prefs.toJson())
            })
        }

        val timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd-HHmmss"))
        val file = File(context.cacheDir, "natasaku-backup-$timestamp.json")
        file.writeText(root.toString(2), Charsets.UTF_8)
        val uri = runCatching { FileProvider.getUriForFile(context, context.packageName + AUTHORITY_SUFFIX, file) }.getOrElse { Uri.fromFile(file) }
        return ExportedFileUiModel(file.name, uri, "application/json", file.length(), Instant.now())
    }

    suspend fun restoreFromJson(
        jsonText: String,
        restoreMode: RestoreMode = RestoreMode.REPLACE_ALL,
    ): Result<Unit> = runCatching {
        val root = BackupRestoreValidator.parseJsonOrError(jsonText).getOrThrow()
        validate(root)
        val data = root.getJSONObject("data")
        db.withTransaction {
            if (restoreMode == RestoreMode.REPLACE_ALL) {
                backupRestoreDao.clearDailyBudgetSnapshots(); backupRestoreDao.clearSavingAllocations(); backupRestoreDao.clearSavingTargets()
                backupRestoreDao.clearExpenseTransactions(); backupRestoreDao.clearFixedExpenses(); backupRestoreDao.clearIncomeSources(); backupRestoreDao.clearBudgetPeriods()
                backupRestoreDao.clearScheduledSavingExecutions(); backupRestoreDao.clearScheduledPaymentExecutions()
                backupRestoreDao.clearScheduledSavings(); backupRestoreDao.clearScheduledPayments()

                budgetPeriodDao.upsertAll(data.getJSONArray("budgetPeriods").toBudgetPeriods())
                incomeSourceDao.upsertAll(data.getJSONArray("incomeSources").toIncome())
                fixedExpenseDao.upsertAll(data.getJSONArray("fixedExpenses").toFixed())
                transactionDao.upsertAll(data.getJSONArray("expenseTransactions").toTransactions())
                savingTargetDao.upsertAll(data.getJSONArray("savingTargets").toTargets())
                savingAllocationDao.upsertAll(data.getJSONArray("savingAllocations").toAllocations())
                dailyBudgetSnapshotDao.upsertAll(data.getJSONArray("dailyBudgetSnapshots").toSnapshots())
                scheduledPaymentDao.upsertAll(data.optJSONArray("scheduledPayments")?.toScheduledPayments().orEmpty())
                scheduledSavingDao.upsertAll(data.optJSONArray("scheduledSavings")?.toScheduledSavings().orEmpty())
                data.optJSONArray("scheduledPaymentExecutions")?.toScheduledPaymentExecutions().orEmpty()
                    .forEach { scheduledPaymentExecutionDao.upsert(it) }
                data.optJSONArray("scheduledSavingExecutions")?.toScheduledSavingExecutions().orEmpty()
                    .forEach { scheduledSavingExecutionDao.upsert(it) }
            } else {
                val existingPeriods = budgetPeriodDao.observeAll().first().map { it.id }.toSet()
                budgetPeriodDao.upsertAll(data.getJSONArray("budgetPeriods").toBudgetPeriods().filterNot { it.id in existingPeriods })

                val existingIncome = incomeSourceDao.observeAll().first().map { it.id }.toSet()
                incomeSourceDao.upsertAll(data.getJSONArray("incomeSources").toIncome().filterNot { it.id in existingIncome })

                val existingFixed = fixedExpenseDao.observeAll().first().map { it.id }.toSet()
                fixedExpenseDao.upsertAll(data.getJSONArray("fixedExpenses").toFixed().filterNot { it.id in existingFixed })

                val existingTx = transactionDao.observeAll().first().map { it.id }.toSet()
                transactionDao.upsertAll(data.getJSONArray("expenseTransactions").toTransactions().filterNot { it.id in existingTx })

                val existingTargets = savingTargetDao.observeAll().first().map { it.id }.toSet()
                savingTargetDao.upsertAll(data.getJSONArray("savingTargets").toTargets().filterNot { it.id in existingTargets })

                val existingAllocs = savingAllocationDao.observeAll().first().map { it.id }.toSet()
                savingAllocationDao.upsertAll(data.getJSONArray("savingAllocations").toAllocations().filterNot { it.id in existingAllocs })

                val existingSnapshots = dailyBudgetSnapshotDao.observeAll().first().map { it.id }.toSet()
                dailyBudgetSnapshotDao.upsertAll(data.getJSONArray("dailyBudgetSnapshots").toSnapshots().filterNot { it.id in existingSnapshots })

                val existingScheduledPayments = scheduledPaymentDao.observeAll().first().map { it.id }.toSet()
                scheduledPaymentDao.upsertAll(
                    data.optJSONArray("scheduledPayments")?.toScheduledPayments().orEmpty().filterNot { it.id in existingScheduledPayments },
                )

                val existingScheduledSavings = scheduledSavingDao.observeAll().first().map { it.id }.toSet()
                scheduledSavingDao.upsertAll(
                    data.optJSONArray("scheduledSavings")?.toScheduledSavings().orEmpty().filterNot { it.id in existingScheduledSavings },
                )

                val existingScheduledPaymentExec = data.optJSONArray("scheduledPaymentExecutions")?.toScheduledPaymentExecutions().orEmpty()
                existingScheduledPaymentExec.forEach { scheduledPaymentExecutionDao.upsert(it) }
                val existingScheduledSavingExec = data.optJSONArray("scheduledSavingExecutions")?.toScheduledSavingExecutions().orEmpty()
                existingScheduledSavingExec.forEach { scheduledSavingExecutionDao.upsert(it) }
            }
            preferenceDataStore.update(data.getJSONObject("preferences").toPreference())
        }
    }

    private fun validate(root: JSONObject) {
        require(root.optString("app") == "NataSaku") { "File backup tidak bisa dibaca. Pastikan file berasal dari NataSaku." }
        require(BackupRestoreValidator.validateSchemaVersion(root).isValid) {
            "Versi backup tidak kompatibel. Backup ini dibuat di versi lama NataSaku."
        }
        val data = root.optJSONObject("data") ?: error("Data backup tidak tersedia.")
        val required = listOf("budgetPeriods", "incomeSources", "fixedExpenses", "expenseTransactions", "savingTargets", "savingAllocations", "dailyBudgetSnapshots", "preferences")
        require(required.all { data.has(it) }) { "Struktur backup tidak lengkap." }
    }
}

private fun BudgetPeriodEntity.toJson() = JSONObject().put("id", id).put("name", name).put("startDate", startDate.toString()).put("endDate", endDate.toString()).put("isActive", isActive).put("createdAt", createdAt.toEpochMilli()).put("updatedAt", updatedAt.toEpochMilli())
private fun FixedExpenseEntity.toJson() = JSONObject().put("id", id).put("periodId", periodId).put("name", name).put("amount", amount).put("dueDay", dueDay).put("status", status.name).put("snoozedUntilTs", snoozedUntilTs?.toEpochMilli()).put("paidAt", paidAt?.toEpochMilli()).put("createdAt", createdAt.toEpochMilli())
private fun ExpenseTransactionEntity.toJson() = JSONObject().put("id", id).put("periodId", periodId).put("amount", amount).put("category", category).put("date", date.toString()).put("note", note).put("createdAt", createdAt.toEpochMilli()).put("updatedAt", updatedAt.toEpochMilli()).put("deletedAt", deletedAt?.toEpochMilli()).put("source", source.name).put("fixedExpenseId", fixedExpenseId)
private fun ScheduledPaymentEntity.toJson() = JSONObject()
    .put("id", id)
    .put("name", name)
    .put("amount", amount)
    .put("categoryId", categoryId)
    .put("dayOfMonth", dayOfMonth)
    .put("frequency", frequency.name)
    .put("customIntervalDays", customIntervalDays)
    .put("startDate", startDate.toString())
    .put("endDate", endDate?.toString())
    .put("isActive", isActive)
    .put("note", note)
    .put("lastExecutedDate", lastExecutedDate?.toString())
    .put("createdAt", createdAt.toEpochMilli())
private fun ScheduledPaymentExecutionEntity.toJson() = JSONObject()
    .put("id", id)
    .put("scheduledPaymentId", scheduledPaymentId)
    .put("executedDate", executedDate.toString())
    .put("transactionId", transactionId)
    .put("status", status.name)
private fun ScheduledSavingEntity.toJson() = JSONObject()
    .put("id", id)
    .put("savingTargetId", savingTargetId)
    .put("name", name)
    .put("amountPerExecution", amountPerExecution)
    .put("frequency", frequency.name)
    .put("dayOfMonth", dayOfMonth)
    .put("dayOfWeek", dayOfWeek)
    .put("startDate", startDate.toString())
    .put("endDate", endDate?.toString())
    .put("isActive", isActive)
    .put("lastExecutedDate", lastExecutedDate?.toString())
    .put("createdAt", createdAt.toEpochMilli())
private fun ScheduledSavingExecutionEntity.toJson() = JSONObject()
    .put("id", id)
    .put("scheduledSavingId", scheduledSavingId)
    .put("executedDate", executedDate.toString())
    .put("savingAllocationId", savingAllocationId)
    .put("amount", amount)
    .put("status", status)
private fun UserPreference.toJson() = JSONObject()
    .put("currencyCode", currencyCode)
    .put("themeMode", themeMode.name)
    .put("defaultLeftoverAllocation", defaultLeftoverAllocation.name)
    .put("dailyReminderEnabled", dailyReminderEnabled)
    .put("dailyReminderTime", dailyReminderTime)
    .put("onboardingCompleted", onboardingCompleted)
    .put("activePeriodId", activePeriodId)
    .put("migrationV1Done", migrationV1Done)
    .put("lastBackupAtEpochMillis", lastBackupAtEpochMillis)
    .put("lastBackupReminderDismissedAtEpochMillis", lastBackupReminderDismissedAtEpochMillis)
    .put("tourCompleted", tourCompleted)

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
private fun JSONArray.toScheduledPayments() = (0 until length()).map { i -> getJSONObject(i) }.map {
    ScheduledPaymentEntity(
        id = it.optLong("id", 0L),
        name = it.getString("name"),
        amount = it.getLong("amount"),
        categoryId = it.optLong("categoryId", 0L),
        dayOfMonth = it.optInt("dayOfMonth", 1),
        frequency = runCatching { PaymentFrequency.valueOf(it.optString("frequency", PaymentFrequency.MONTHLY.name)) }.getOrDefault(PaymentFrequency.MONTHLY),
        customIntervalDays = if (it.isNull("customIntervalDays")) null else it.optInt("customIntervalDays"),
        startDate = LocalDate.parse(it.getString("startDate")),
        endDate = if (it.isNull("endDate")) null else LocalDate.parse(it.getString("endDate")),
        isActive = it.optBoolean("isActive", true),
        note = it.optString("note").ifBlank { null },
        lastExecutedDate = if (it.isNull("lastExecutedDate")) null else LocalDate.parse(it.getString("lastExecutedDate")),
        createdAt = if (it.has("createdAt")) Instant.ofEpochMilli(it.getLong("createdAt")) else Instant.now(),
    )
}
private fun JSONArray.toScheduledPaymentExecutions() = (0 until length()).map { i -> getJSONObject(i) }.map {
    ScheduledPaymentExecutionEntity(
        id = it.optLong("id", 0L),
        scheduledPaymentId = it.getLong("scheduledPaymentId"),
        executedDate = LocalDate.parse(it.getString("executedDate")),
        transactionId = it.optString("transactionId"),
        status = runCatching { ExecutionStatus.valueOf(it.optString("status", ExecutionStatus.SUCCESS.name)) }.getOrDefault(ExecutionStatus.SUCCESS),
    )
}
private fun JSONArray.toScheduledSavings() = (0 until length()).map { i -> getJSONObject(i) }.map {
    ScheduledSavingEntity(
        id = it.optLong("id", 0L),
        savingTargetId = it.getString("savingTargetId"),
        name = it.getString("name"),
        amountPerExecution = it.getLong("amountPerExecution"),
        frequency = runCatching { SavingFrequency.valueOf(it.optString("frequency", SavingFrequency.MONTHLY.name)) }.getOrDefault(SavingFrequency.MONTHLY),
        dayOfMonth = if (it.isNull("dayOfMonth")) null else it.optInt("dayOfMonth"),
        dayOfWeek = if (it.isNull("dayOfWeek")) null else it.optInt("dayOfWeek"),
        startDate = LocalDate.parse(it.getString("startDate")),
        endDate = if (it.isNull("endDate")) null else LocalDate.parse(it.getString("endDate")),
        isActive = it.optBoolean("isActive", true),
        lastExecutedDate = if (it.isNull("lastExecutedDate")) null else LocalDate.parse(it.getString("lastExecutedDate")),
        createdAt = if (it.has("createdAt")) Instant.ofEpochMilli(it.getLong("createdAt")) else Instant.now(),
    )
}
private fun JSONArray.toScheduledSavingExecutions() = (0 until length()).map { i -> getJSONObject(i) }.map {
    ScheduledSavingExecutionEntity(
        id = it.optLong("id", 0L),
        scheduledSavingId = it.getLong("scheduledSavingId"),
        executedDate = LocalDate.parse(it.getString("executedDate")),
        savingAllocationId = it.optString("savingAllocationId"),
        amount = it.optLong("amount", 0L),
        status = it.optString("status", "SUCCESS"),
    )
}

private fun JSONObject.toPreference() = UserPreference(
    currencyCode = optString("currencyCode", "IDR"),
    themeMode = runCatching { ThemeMode.valueOf(optString("themeMode", "SYSTEM")) }.getOrDefault(ThemeMode.SYSTEM),
    defaultLeftoverAllocation = runCatching { DefaultLeftoverAllocation.valueOf(optString("defaultLeftoverAllocation", "ASK_EVERY_TIME")) }.getOrDefault(DefaultLeftoverAllocation.ASK_EVERY_TIME),
    dailyReminderEnabled = optBoolean("dailyReminderEnabled", false),
    dailyReminderTime = optString("dailyReminderTime", "20:00"),
    onboardingCompleted = optBoolean("onboardingCompleted", false),
    activePeriodId = if (isNull("activePeriodId")) null else optString("activePeriodId"),
    migrationV1Done = optBoolean("migrationV1Done", false),
    lastBackupAtEpochMillis = optLong("lastBackupAtEpochMillis", 0L),
    lastBackupReminderDismissedAtEpochMillis = optLong("lastBackupReminderDismissedAtEpochMillis", 0L),
    tourCompleted = optBoolean("tourCompleted", false),
)

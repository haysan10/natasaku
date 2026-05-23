package com.natasaku.app.reminder

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.util.Base64
import android.webkit.JavascriptInterface
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.natasaku.app.R
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream
import java.time.LocalDate
import java.time.LocalDateTime
import org.json.JSONArray
import org.json.JSONObject

class NataSakuWebBridge(
    private val context: Context,
    private val store: ExpenseReminderStore,
    private val scheduler: ExpenseReminderScheduler,
) {
    @Volatile
    private var lastExportError: String = ""

    @JavascriptInterface
    fun syncReminderSnapshot(snapshotJson: String) {
        store.syncFromWebSnapshot(snapshotJson)
        scheduler.scheduleNext()
    }

    @JavascriptInterface
    fun consumePendingQuickTransactions(): String {
        return store.consumePendingTransactionsJson()
    }

    @JavascriptInterface
    fun getReminderHoursCsv(): String {
        return store.getReminderHours().joinToString(",")
    }

    @JavascriptInterface
    fun acknowledgeExpenseToday() {
        store.markExpenseForDate(LocalDate.now())
        scheduler.scheduleNext()
    }

    @JavascriptInterface
    fun getNotificationPermissionStatus(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return "granted"
        val granted = ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        return if (granted) "granted" else "denied"
    }

    @JavascriptInterface
    fun sendTestNotificationNow(): Boolean {
        if (getNotificationPermissionStatus() != "granted") return false
        createDiagnosticChannel()
        val notification = NotificationCompat.Builder(context, DIAG_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_small)
            .setContentTitle("Tes Notifikasi NataSaku")
            .setContentText("Notifikasi aktif. Semua sistem reminder siap digunakan.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()
        NotificationManagerCompat.from(context).notify(DIAG_TEST_NOTIFICATION_ID, notification)
        return true
    }

    @JavascriptInterface
    fun runReminderSimulation(snapshotJson: String): String {
        val now = LocalDateTime.now()
        val today = LocalDate.now()
        val reminderHours = store.getReminderHours()
        val currentHour = now.hour
        val withinReminderHour = reminderHours.contains(currentHour)
        val hasExpenseTodayStore = store.hasExpenseForDate(today)
        val muted = store.getMuteUntilMs() > System.currentTimeMillis()
        val slotKey = "${today}-${currentHour}"
        val promptedThisSlot = store.wasPromptedInSlot(slotKey)
        val permissionGranted = getNotificationPermissionStatus() == "granted"

        val hasExpenseTodaySnapshot = runCatching {
            JSONObject(snapshotJson).optBoolean("hasExpenseToday", false)
        }.getOrDefault(false)
        val hasExpenseToday = hasExpenseTodayStore || hasExpenseTodaySnapshot

        val reasons = mutableListOf<String>()
        if (!permissionGranted) reasons += "Izin notifikasi belum diizinkan."
        if (hasExpenseToday) reasons += "Hari ini sudah ada pengeluaran tercatat."
        if (muted) reasons += "Reminder sedang ditunda (mute/snooze) sementara."
        if (promptedThisSlot) reasons += "Slot jam ini sudah pernah diprompt."
        if (!withinReminderHour) reasons += "Jam saat ini di luar daftar reminder (${reminderHours.joinToString(", ")})."

        val eligible = permissionGranted && !hasExpenseToday && !muted && !promptedThisSlot && withinReminderHour
        if (eligible) {
            reasons += "Semua syarat terpenuhi."
        }

        return JSONObject()
            .put("eligible", eligible)
            .put("permissionGranted", permissionGranted)
            .put("hasExpenseToday", hasExpenseToday)
            .put("muted", muted)
            .put("promptedThisSlot", promptedThisSlot)
            .put("withinReminderHour", withinReminderHour)
            .put("currentHour", currentHour)
            .put("reminderHours", JSONArray(reminderHours))
            .put("reasons", JSONArray(reasons))
            .toString()
    }

    @JavascriptInterface
    fun exportCsv(fileName: String, content: String): Boolean {
        return exportTextFile(
            fileName = sanitizeFileName(fileName, "csv"),
            content = content,
            mimeType = "text/csv",
        )
    }

    @JavascriptInterface
    fun exportPdfBase64(fileName: String, base64Content: String): Boolean {
        return runCatching {
            val safeName = sanitizeFileName(fileName, "pdf")
            val dir = File(context.cacheDir, "exports").apply { mkdirs() }
            val outputFile = File(dir, safeName)
            val normalizedBase64 = base64Content
                .substringAfter(",", base64Content)
                .replace("\\s".toRegex(), "")

            val bytes = runCatching {
                Base64.decode(normalizedBase64, Base64.DEFAULT)
            }.recoverCatching {
                Base64.decode(normalizedBase64, Base64.URL_SAFE)
            }.getOrElse {
                throw IllegalArgumentException("Base64 PDF tidak valid.")
            }

            if (bytes.isEmpty()) {
                throw IllegalStateException("Konten PDF kosong.")
            }

            FileOutputStream(outputFile).use { it.write(bytes) }
            shareFile(outputFile, "application/pdf")
            lastExportError = ""
            true
        }.getOrElse { err ->
            lastExportError = err.message ?: err.javaClass.simpleName
            false
        }
    }

    private fun exportTextFile(fileName: String, content: String, mimeType: String): Boolean {
        return runCatching {
            val dir = File(context.cacheDir, "exports").apply { mkdirs() }
            val outputFile = File(dir, fileName)
            outputFile.writeText(content, Charsets.UTF_8)
            shareFile(outputFile, mimeType)
            lastExportError = ""
            true
        }.getOrElse { err ->
            lastExportError = err.message ?: err.javaClass.simpleName
            false
        }
    }

    @JavascriptInterface
    fun getLastExportError(): String = lastExportError

    private fun shareFile(file: File, mimeType: String) {
        val uri: Uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            file,
        )
        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(Intent.createChooser(shareIntent, "Bagikan laporan"))
    }

    private fun createDiagnosticChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            DIAG_CHANNEL_ID,
            "Tes Notifikasi NataSaku",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Channel untuk tes notifikasi dari menu setup."
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    private fun sanitizeFileName(input: String, fallbackExt: String): String {
        val cleaned = input
            .trim()
            .replace(Regex("[^a-zA-Z0-9._-]"), "_")
            .trim('_')
            .ifBlank { "NataSaku_Export.$fallbackExt" }
        return if (cleaned.contains(".")) cleaned else "$cleaned.$fallbackExt"
    }

    companion object {
        private const val DIAG_CHANNEL_ID = "natasaku_notification_diag"
        private const val DIAG_TEST_NOTIFICATION_ID = 55110
    }
}

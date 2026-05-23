package com.natasaku.app.domain.validation

import org.json.JSONObject

object BackupRestoreValidator {
    const val CURRENT_SCHEMA_VERSION = 3

    data class RestoreValidationResult(
        val blockingError: String? = null,
    ) {
        val isValid: Boolean = blockingError == null
    }

    fun validateFileName(fileName: String): RestoreValidationResult {
        return if (!fileName.lowercase().endsWith(".json")) {
            RestoreValidationResult(blockingError = "File tidak dikenali. Pilih file backup NataSaku (.json)")
        } else {
            RestoreValidationResult()
        }
    }

    fun parseJsonOrError(raw: String): Result<JSONObject> {
        return runCatching { JSONObject(raw) }.mapErrorMessage(
            "File backup rusak atau bukan dari NataSaku",
        )
    }

    fun validateSchemaVersion(root: JSONObject): RestoreValidationResult {
        val schema = root.optInt("schemaVersion", -1)
        return if (schema != CURRENT_SCHEMA_VERSION) {
            RestoreValidationResult(
                blockingError = "Versi backup tidak kompatibel. Backup ini dibuat di versi lama NataSaku.",
            )
        } else {
            RestoreValidationResult()
        }
    }

    private fun <T> Result<T>.mapErrorMessage(message: String): Result<T> {
        return fold(
            onSuccess = { Result.success(it) },
            onFailure = { Result.failure(IllegalArgumentException(message)) },
        )
    }
}

package com.natasaku.app.domain.validation

import org.junit.Assert.assertFalse
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class BackupRestoreValidatorTest {
    @Test
    fun nonJsonFile_blocked() {
        val result = BackupRestoreValidator.validateFileName("backup.txt")
        assertFalse(result.isValid)
        assertEquals("File tidak dikenali. Pilih file backup NataSaku (.json)", result.blockingError)
    }

    @Test
    fun invalidJson_blocked() {
        val result = BackupRestoreValidator.parseJsonOrError("{]")
        assertTrue(result.isFailure)
    }

    @Test
    fun wrongSchema_blocked() {
        val json = BackupRestoreValidator.parseJsonOrError(
            """{"app":"NataSaku","schemaVersion":1,"data":{}}""",
        ).getOrThrow()
        val validation = BackupRestoreValidator.validateSchemaVersion(json)
        assertFalse(validation.isValid)
    }

    @Test
    fun matchingSchema_valid() {
        val json = BackupRestoreValidator.parseJsonOrError(
            """{"app":"NataSaku","schemaVersion":3,"data":{}}""",
        ).getOrThrow()
        val validation = BackupRestoreValidator.validateSchemaVersion(json)
        assertTrue(validation.isValid)
    }
}

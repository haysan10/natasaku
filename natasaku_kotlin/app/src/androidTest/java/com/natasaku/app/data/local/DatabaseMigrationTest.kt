package com.natasaku.app.data.local

import androidx.room.testing.MigrationTestHelper
import androidx.sqlite.db.framework.FrameworkSQLiteOpenHelperFactory
import androidx.test.platform.app.InstrumentationRegistry
import com.natasaku.app.data.local.database.DatabaseMigrations
import org.junit.Rule
import org.junit.Test

class DatabaseMigrationTest {
    private val testDb = "migration-test"

    @get:Rule
    val helper: MigrationTestHelper = MigrationTestHelper(
        InstrumentationRegistry.getInstrumentation(),
        "com.natasaku.app.data.local.database.NataSakuDatabase",
        FrameworkSQLiteOpenHelperFactory(),
    )

    @Test
    fun migrate2To3_createsScheduledTables() {
        helper.createDatabase(testDb, 2).apply {
            execSQL(
                """
                CREATE TABLE IF NOT EXISTS `budget_period` (
                  `id` TEXT NOT NULL PRIMARY KEY,
                  `name` TEXT NOT NULL,
                  `startDate` TEXT NOT NULL,
                  `endDate` TEXT NOT NULL,
                  `isActive` INTEGER NOT NULL,
                  `createdAt` INTEGER NOT NULL,
                  `updatedAt` INTEGER NOT NULL
                )
                """.trimIndent(),
            )
            close()
        }
        helper.runMigrationsAndValidate(
            testDb,
            3,
            true,
            DatabaseMigrations.MIGRATION_2_3,
        )
    }
}

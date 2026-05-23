package com.natasaku.app.data.local.database

import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase

object DatabaseMigrations {
    val MIGRATION_2_3 = object : Migration(2, 3) {
        override fun migrate(database: SupportSQLiteDatabase) {
            database.execSQL(
                """
                CREATE TABLE IF NOT EXISTS `scheduled_payment` (
                    `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                    `name` TEXT NOT NULL,
                    `amount` INTEGER NOT NULL,
                    `categoryId` INTEGER NOT NULL,
                    `dayOfMonth` INTEGER NOT NULL,
                    `frequency` TEXT NOT NULL,
                    `customIntervalDays` INTEGER,
                    `startDate` TEXT NOT NULL,
                    `endDate` TEXT,
                    `isActive` INTEGER NOT NULL,
                    `note` TEXT,
                    `lastExecutedDate` TEXT,
                    `createdAt` INTEGER NOT NULL
                )
                """.trimIndent(),
            )
            database.execSQL("CREATE INDEX IF NOT EXISTS `index_scheduled_payment_isActive` ON `scheduled_payment` (`isActive`)")
            database.execSQL("CREATE INDEX IF NOT EXISTS `index_scheduled_payment_startDate` ON `scheduled_payment` (`startDate`)")
            database.execSQL("CREATE INDEX IF NOT EXISTS `index_scheduled_payment_lastExecutedDate` ON `scheduled_payment` (`lastExecutedDate`)")

            database.execSQL(
                """
                CREATE TABLE IF NOT EXISTS `scheduled_payment_execution` (
                    `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                    `scheduledPaymentId` INTEGER NOT NULL,
                    `executedDate` TEXT NOT NULL,
                    `transactionId` TEXT NOT NULL,
                    `status` TEXT NOT NULL
                )
                """.trimIndent(),
            )
            database.execSQL("CREATE INDEX IF NOT EXISTS `index_scheduled_payment_execution_scheduledPaymentId` ON `scheduled_payment_execution` (`scheduledPaymentId`)")
            database.execSQL("CREATE UNIQUE INDEX IF NOT EXISTS `index_scheduled_payment_execution_scheduledPaymentId_executedDate` ON `scheduled_payment_execution` (`scheduledPaymentId`, `executedDate`)")

            database.execSQL(
                """
                CREATE TABLE IF NOT EXISTS `scheduled_saving` (
                    `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                    `savingTargetId` TEXT NOT NULL,
                    `name` TEXT NOT NULL,
                    `amountPerExecution` INTEGER NOT NULL,
                    `frequency` TEXT NOT NULL,
                    `dayOfMonth` INTEGER,
                    `dayOfWeek` INTEGER,
                    `startDate` TEXT NOT NULL,
                    `endDate` TEXT,
                    `isActive` INTEGER NOT NULL,
                    `lastExecutedDate` TEXT,
                    `createdAt` INTEGER NOT NULL
                )
                """.trimIndent(),
            )
            database.execSQL("CREATE INDEX IF NOT EXISTS `index_scheduled_saving_savingTargetId` ON `scheduled_saving` (`savingTargetId`)")
            database.execSQL("CREATE INDEX IF NOT EXISTS `index_scheduled_saving_isActive` ON `scheduled_saving` (`isActive`)")
            database.execSQL("CREATE INDEX IF NOT EXISTS `index_scheduled_saving_lastExecutedDate` ON `scheduled_saving` (`lastExecutedDate`)")

            database.execSQL(
                """
                CREATE TABLE IF NOT EXISTS `scheduled_saving_execution` (
                    `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                    `scheduledSavingId` INTEGER NOT NULL,
                    `executedDate` TEXT NOT NULL,
                    `savingAllocationId` TEXT NOT NULL,
                    `amount` INTEGER NOT NULL,
                    `status` TEXT NOT NULL
                )
                """.trimIndent(),
            )
            database.execSQL("CREATE INDEX IF NOT EXISTS `index_scheduled_saving_execution_scheduledSavingId` ON `scheduled_saving_execution` (`scheduledSavingId`)")
            database.execSQL("CREATE UNIQUE INDEX IF NOT EXISTS `index_scheduled_saving_execution_scheduledSavingId_executedDate` ON `scheduled_saving_execution` (`scheduledSavingId`, `executedDate`)")

            database.execSQL("CREATE INDEX IF NOT EXISTS `index_expense_transaction_category` ON `expense_transaction` (`category`)")
        }
    }
}

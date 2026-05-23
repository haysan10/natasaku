package com.natasaku.app.data.local.database

import android.content.Context
import androidx.room.Room

object DatabaseProvider {
    @Volatile
    private var instance: NataSakuDatabase? = null

    fun get(context: Context): NataSakuDatabase {
        return instance ?: synchronized(this) {
            instance ?: Room.databaseBuilder(
                context.applicationContext,
                NataSakuDatabase::class.java,
                "natasaku.db",
            )
                .addMigrations(DatabaseMigrations.MIGRATION_2_3)
                .build()
                .also { instance = it }
        }
    }
}

package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.SavingTargetEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SavingTargetDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(target: SavingTargetEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(items: List<SavingTargetEntity>)

    @Query("SELECT * FROM saving_target")
    fun observeAll(): Flow<List<SavingTargetEntity>>

    @Query("SELECT * FROM saving_target WHERE periodId = :periodId LIMIT 1")
    fun observeByPeriod(periodId: String): Flow<SavingTargetEntity?>
}

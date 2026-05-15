package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.SavingAllocationEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SavingAllocationDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(allocation: SavingAllocationEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(items: List<SavingAllocationEntity>)

    @Query("SELECT * FROM saving_allocation ORDER BY date DESC")
    fun observeAll(): Flow<List<SavingAllocationEntity>>

    @Query("SELECT * FROM saving_allocation WHERE periodId = :periodId ORDER BY date DESC")
    fun observeByPeriod(periodId: String): Flow<List<SavingAllocationEntity>>
}

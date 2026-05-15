package com.natasaku.app.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import java.time.Instant
import kotlinx.coroutines.flow.Flow

@Dao
interface ExpenseTransactionDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(transaction: ExpenseTransactionEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertAll(items: List<ExpenseTransactionEntity>)

    @Query("SELECT * FROM expense_transaction ORDER BY date DESC, createdAt DESC")
    fun observeAll(): Flow<List<ExpenseTransactionEntity>>

    @Query("""
        SELECT * FROM expense_transaction
        WHERE periodId = :periodId AND deletedAt IS NULL
        ORDER BY date DESC, createdAt DESC
    """)
    fun observeByPeriod(periodId: String): Flow<List<ExpenseTransactionEntity>>

    @Query("""
        SELECT * FROM expense_transaction
        WHERE periodId = :periodId
        AND deletedAt IS NULL
        AND (:query = '' OR category LIKE '%' || :query || '%' OR note LIKE '%' || :query || '%')
        ORDER BY date DESC, createdAt DESC
    """)
    fun observeByPeriodAndQuery(periodId: String, query: String): Flow<List<ExpenseTransactionEntity>>

    @Query("UPDATE expense_transaction SET deletedAt = :deletedAt WHERE id = :id")
    suspend fun softDelete(id: String, deletedAt: Instant)
}
